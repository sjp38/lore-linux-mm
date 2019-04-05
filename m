Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB4C5C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3B9B21738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3B9B21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1275A6B026B; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097DA6B026D; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA1E66B026E; Fri,  5 Apr 2019 09:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4276B026B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:51:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d2so3177936edo.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:51:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=lzcy0m9Ct3wLhEZq/mTvC0ituY1HDTmyz8m7K/d4ouM=;
        b=MSiqXbnj8oPMpybEZlIkFTu1X2WEhfKxat3FzmIE7JH0ohOEjvq572+egLeusm5VfL
         sYElXiH8GkTt5UoWAQeoifD279nB0UsTbV6I3wgePqRRRsCp1SW2nBcUtt1dMgoqXrHW
         wBCCwvpE19pM9pXGwihGP9ujC4FccVbTsDbR2LeP723AC+U1rxKzgmb40cl9VErUtclI
         0LVTMhEriaMQM2bdLnwmDTsL6HqtYDiISy0yJOwAp9LpE+5+a10BzzvTxZMoAf+QfSTB
         6qVWHhEfVB3GUlX87zGoOC+egPNgU2Wh7DV2fu2fC9d//gkA6WK07tM7sxWVU766oedY
         A3zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUQ9EZAUOhXiG1UIcuoGRYC2OZd+pQlaJsXRyKYIS9SGzrqz9tP
	h/8l4lYr01teJNbWoiNXtOYvT+x0iqBm0sB9reC0+H/KTuUT2N/iFLU2YcaOAs3Z6l5yT/bvyPB
	3l1/W/Mfru+IrYGsWTHSthun9UdM5xmqnSSF5gJR6dw4NT1kiBmfSGIkrRuGYkk9NSQ==
X-Received: by 2002:a50:b3b1:: with SMTP id s46mr8330440edd.202.1554472283024;
        Fri, 05 Apr 2019 06:51:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjsWsECZ00WBCGMy5NP83D7jkKaH4SyzbxAuYi5FBtRK7qI+p5IvxSoFTyME6kIUMdFxeY
X-Received: by 2002:a50:b3b1:: with SMTP id s46mr8330380edd.202.1554472281999;
        Fri, 05 Apr 2019 06:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554472281; cv=none;
        d=google.com; s=arc-20160816;
        b=oR6FWMFAfZa4Gh2UPLaZF6oiwhh7gzMVXKcfLHVbsAIBlYhAECJMr7qvkC8DF9fqNr
         /KlFUrZO1z12Jd2nAbE6lL0bIWgjRKIFm4LZ3X0OuTmRMYYpmIpHddxVzMdErh0TfiWe
         sNIOZNrqjBMojOwiS2tN3XaQpU66mPt7P2R9mlGKBdXn+AyUwjshueoZtDB8KBcAiOLw
         xaPk9h9is6LBdv+T0wYH7+7ebFUMUw9BLrcdtEzU0oGfeA9pr1nvUnP372l59ls8iLgi
         T97bZp2jd3BQMHzRl43SH+cT2DYBTBu5ifdv9efPIeA9xF2sHj/i0mxUKkVPzFj6Oq9B
         is8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=lzcy0m9Ct3wLhEZq/mTvC0ituY1HDTmyz8m7K/d4ouM=;
        b=NvY6g4I4yxSXdmEBm8XWvLosbwVnC4Fy8/p9PKuXCooxgerDhoc6uAYeI7S+lpPmxa
         Lz+t1Bbzna1uqy/oyzwILtk+Va/01MOktHgljFme71/A/FRzYzNBSXEe9kEuzj1lvMkb
         InQCwqaAsYb0s4cCxwcaqsY0j5OhoPFsKeAkI25p55CdBNId21MsUKErBWuN9XaS3VRa
         qlnCMZENKWAvrz5EP/tFlpKmVcEH0Su6zdvbEiWSqK0KshxNlZIeEQmYgIiblx3DcJH/
         0SBri+wPc5KlY+mxFaEAjU5u2yqxuvuGLT3LmOuyG7uxkt2AYQJjMAI3v1fz416MsrBP
         qfiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp21.blacknight.com (outbound-smtp21.blacknight.com. [81.17.249.41])
        by mx.google.com with ESMTPS id c2si934203edl.204.2019.04.05.06.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 06:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) client-ip=81.17.249.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp21.blacknight.com (Postfix) with ESMTPS id 3C6DAB8B74
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 14:51:21 +0100 (IST)
Received: (qmail 28386 invoked from network); 5 Apr 2019 13:51:21 -0000
Received: from unknown (HELO stampy.163woodhaven.lan) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPA; 5 Apr 2019 13:51:21 -0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Linus Torvalds <torvalds@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [GIT PULL] mm/compaction functional fixes for v5.1-rc4
Date: Fri,  5 Apr 2019 14:51:18 +0100
Message-Id: <20190405135120.27532-1-mgorman@techsingularity.net>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The following changes since commit 79a3aaa7b82e3106be97842dedfd8429248896e6:

  Linux 5.1-rc3 (2019-03-31 14:39:29 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git tags/mm-compaction-5.1-rc4

for you to fetch changes up to 5b56d996dd50a9d2ca87c25ebb50c07b255b7e04:

  mm/compaction.c: abort search if isolation fails (2019-04-04 11:56:15 +0100)

----------------

Hi Linus,

The merge window for 5.1 introduced a number of compaction-related patches
authored by myself.  There are intermittent reports of corruption and
functional issues based on them due to sloppy checking of zone boundaries
and a corner case where the free lists are overrun.

Reports are not common but at least two users and 0-day have tripped over them.
There is a chance that one of the syzbot reports are related but it has not
been confirmed properly.

The normal submission path is through Andrew but it's now late on a Friday
and I do not know if a round of updates are coming your way or not and
these patches have been floating around for a while. Given the nature
of the fixes, I really would prefer to avoid another RC with corruption
issues creating duplicate reports.

All of these have been successfully tested on older RC windows. This will
make this branch look like a rebase but they've simply been cherry-picked
from Andrew's tree and placed on a fresh branch. I've no reason to
believe that this has invalidated the testing given the lack of change
in compaction and the nature of the fixes.

Note that you may still receive these from Andrew and there are other
compaction-related fixes in his tree that are less critical. I do not
expect them to conflict but there is a non-zero risk of confusion. If
you get a bunch of patches from Andrew then please ignore this entirely
so the normal submission path is preserved. Otherwise, please either git
pull this or pick up the patches directly at your discretion.

Mel Gorman (1):
  mm/compaction.c: correct zone boundary handling when resetting
    pageblock skip hints

Qian Cai (1):
  mm/compaction.c: abort search if isolation fails

 mm/compaction.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

-- 
2.16.4

