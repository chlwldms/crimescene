import 'dart:math';

class GameData {
  // 용의자와 탐정 데이터
  static const List<String> suspects = [
    "김윤복",
    "황윤서",
    "한규상",
    "신예슬",
  ];

  static const List<String> alibis = [
    "8시 이후 알리바이가 없음", // A의 알리바이
    "현장에서 목격됨",         // B의 알리바이
    "친구와 저녁식사를 함께 함", // C의 알리바이
    "집에서 혼자 있었음",       // D의 알리바이
  ];

  static const String detectiveRole = "탐정";

  // 장소별 단서 데이터 (증거물 번호로 나누어 관리)
  static final Map<String, Map<int, String>> locationClues = {
    "shelf": {
      1: "깨진 유리병",
      2: "발자국 사진",
      3: "피 묻은 손수건",
      4: "라벨이 제거된 약품용 병 3개, 모두 사용된 흔적이 있다.",
      5: "물고기 먹이, 라벨에는 붕어, 복어, 구피 전용 사료라고 표기되어있다.",
      6: "페이퍼 나이프, 칼 손잡이에 변색된 핏자국이 남아있다.",
      7: "채혈용 장비, 사망자에게 사용해 혈액형을 알아보자. 사용결과, 사망자의 혈액형은 O형이다.",
      8: "신문이다. 살인 청부업자에 대한 내용이 적혀있다."
    },
    "trash_can": {
      1: "책장 뒤의 메모",
      2: "탐정의 펜",
      3: "의심스러운 열쇠",
      4: "누군가의 노트다. 전화번호 010-0518-0112, 010-4882-5840 2개와 카딜러라는 사이트가 적혀있다. ***핵심증거***",
      5: "피해자의 고등학교 졸업 앨범이다. 찢기고 그을린 흔적이 있다.",
      6: "작은 화분이다. 과다출혈을 일으키는 부위가 표시된 쪽지가 있다. ***주요 증거***",
      7: "성형외과 의사 자격증이다. OOO의 이름이 적혀있다.",
      8: "신예슬의 실험 도구 목록표. 약물 통 하나와 플라스크 한 개가 부족하다."
    },
    "desk": {
      1: "칼에 묻은 핏자국",
      2: "깨진 접시",
      3: "흔적 없는 장갑",
      4: "검은 비닐봉지. 망치가 토막난 채로 들어있다.",
      5: "약품 라벨들. 각각 보톡스, 트리코테신, 펜타닐이라고 적혀있다.",
      6: "사용된 주사기 여러 개",
      7: "황윤서의 지갑. 그녀가 아닌 남자의 카드가 함께 들어있다. ***주요 증거***",
      8: "뺑소니 사고 기록. 주변 기둥에 노란색 페인트가 묻어있다."
    },
    "tab": {
      1: "낡은 사진첩",
      2: "의문의 박스",
      3: "사용된 양초",
      4: "밧줄. 피해자의 방에 있어야 할 장식품을 묶고 있어야 한다.",
      5: "김윤복/한규상/신예슬/황윤서가 들렸던 방의 어항. 어항 안에 소량의 피가 보인다. ***주요 증거***",
      6: "제자 신홍도의 그림. 김이현의 그림과 동일하다.",
      7: "책상 끄트머리에 놓인 공책. 김이현이 신홍도의 그림을 사용했다는 의구심이 적혀있다.",
      8: "기사. 한규상 기자의 허위보도에 대한 비난 여론이 나와 있다."
    },
    "floor": {
      1: "신발 자국",
      2: "뽑힌 꽃",
      3: "범인의 모자",
      4: "녹음기. 신홍도 제자와 김이현의 대화가 담겨있다. ***주요 증거***",
      5: "트레이더 김윤복/신예슬의 휴대폰. 재벌 황윤서와의 통화 기록이 있다.",
      6: "황윤서의 병원 기록. 그녀는 모르핀을 처방받았다.",
      7: "누군가의 테블릿. 황윤서가 구담고 출신이라는 내용이 있다. ***주요 증거***",
      8: "김이현의 주치의 신예슬의 연구 기록. 레시니페라톡신과 트리코테신에 관한 내용이다."
    },
  };

  // 현재 플레이어 역할과 알리바이
  static String? currentRole;
  static String? currentAlibi;

  // 플레이어가 수집한 단서 번호
  static List<String> collectedClues = [];
  static Set<int> collectedClueNumbers = {};

  // 투표 데이터
  static String? votedSuspect;
  static final Map<String, int> votes = {
    "용의자 A": 0,
    "용의자 B": 0,
    "용의자 C": 0,
    "용의자 D": 0,
  };

  /// 역할과 알리바이 랜덤 생성
  static Map<String, dynamic> getRandomRole() {
    final random = Random();
    final bool isDetective = random.nextBool();

    if (isDetective) {
      currentRole = detectiveRole;
      currentAlibi = null; // 탐정은 알리바이가 없음
    } else {
      final int suspectIndex = random.nextInt(suspects.length);
      currentRole = suspects[suspectIndex];
      currentAlibi = alibis[suspectIndex];
    }

    return {"role": currentRole, "alibi": currentAlibi};
  }

  /// 단서 수집 (장소별 단서 번호를 랜덤으로 반환)
  static String? collectClue(String location) {
    final clues = locationClues[location];
    if (clues != null && clues.isNotEmpty) {
      final remainingClueNumbers = clues.keys.toSet().difference(collectedClueNumbers);
      if (remainingClueNumbers.isNotEmpty) {
        final randomClueNumber = remainingClueNumbers.elementAt(Random().nextInt(remainingClueNumbers.length));
        collectedClueNumbers.add(randomClueNumber); // 번호 기록
        final collectedClue = clues[randomClueNumber]; // 단서 반환
        collectedClues.add(collectedClue!); // 수집한 단서 기록
        return collectedClue;
      }
    }
    return null; // 단서가 더 이상 없는 경우
  }

  /// 투표하기
  static void castVote(String suspect) {
    if (suspects.contains(suspect)) {
      votedSuspect = suspect;
      votes[suspect] = (votes[suspect] ?? 0) + 1;
    }
  }

  /// 투표 결과 확인
  static String getVoteResult() {
    final maxVotes = votes.values.reduce((a, b) => a > b ? a : b);
    final winners = votes.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();

    if (winners.length == 1) {
      return "최다 득표: ${winners.first} (${maxVotes}표)";
    } else {
      return "동률: ${winners.join(", ")} (${maxVotes}표)";
    }
  }

  /// 게임 데이터 초기화
  static void resetGameData() {
    // 역할 및 투표 데이터 초기화
    currentRole = null;
    currentAlibi = null;
    votedSuspect = null;
    collectedClues.clear();
    collectedClueNumbers.clear();
    votes.updateAll((key, value) => 0);

    // 장소별 단서 초기화 (전체 목록 다시 설정)
    locationClues.updateAll((key, value) => Map<int, String>.from(value));
  }
}
