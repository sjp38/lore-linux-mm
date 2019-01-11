Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA9A1C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 05:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EEBA20874
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 05:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="edetCLNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EEBA20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0EB68E0002; Fri, 11 Jan 2019 00:52:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E94E58E0001; Fri, 11 Jan 2019 00:52:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D6E8E0002; Fri, 11 Jan 2019 00:52:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2F688E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:52:29 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id x21so5572390oto.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:52:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=Dyqw3HCSpJOE3kTzeE08yEllmbgy+rYjF7ROKuO8WI4=;
        b=ukZlTXvT4736E6cUChYUxtP1C4P75ZfmrwlDgpFmZJTzCyRwqDJl2PYFkbNrZvkWsx
         OahrHJHuxy+fldUMymXorChR2Ywri67ED2tHyUDvSSrg+7ltYl2iiUR6bQMqjYtntfEI
         SDhfQphFj5HY/+7g1EIo/ZaXMhpoh6j32IS2cTePg7t1YB0v6GH/LgmrhGACpkCIU6J5
         KJnOw97uIKQlMYFChRjWv9nZ1OK5N7UNRPb1iQzz+SQ5sYrmLDNhtDfM06Qesg21UaKF
         uGTJVKLN83wwK45l9PmcU9v1hJXmTzljdmZ8kQ9EUFAcirSuPucI/swUAt2s75BfsFGC
         jEPQ==
X-Gm-Message-State: AJcUukeR/3drynefCx8ZZ5tAHaHqSbUU06BUx4xj2NU+4/pbpLqbpMt0
	3XEP7Dr0nGyusl6qqHz6+V0G2dyeE+pC2VjaZ0C+UPeHeiSnfP7NjYZi3fYe7nNyfvIMg2xNDOC
	/VuoUksa7ADQwU9edmioqfufVQN0Ekcn+SJ+7VrZPyX1Qk4ThnUGYEaqgPzXcF1ctHLy1FJoeon
	BWlWJS2L8k2x+qw6qjeW/xz+8JMCe9ZUUSZbh/uojc30SS7VYQ4tvGK8+sCWN2wvFFEnpoz8cQS
	uIlg1E9kz3bxza1Dv6fJj6CNB4oA4Kdh8HUjBD7zjyfM2z+0Pc9S6yO1rnD0kTbUNXmJFWwiCWU
	PZe9u8x9xLM4KtjbMS42QmvxOm7c30mAbi7JVUeKMHqr6clkhR3VSQBxcGhMXz6xUP8gZGADB5+
	9
X-Received: by 2002:a9d:a2d:: with SMTP id 42mr8143310otg.185.1547185949275;
        Thu, 10 Jan 2019 21:52:29 -0800 (PST)
X-Received: by 2002:a9d:a2d:: with SMTP id 42mr8143290otg.185.1547185948492;
        Thu, 10 Jan 2019 21:52:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547185948; cv=none;
        d=google.com; s=arc-20160816;
        b=QPEZ+w3Lrn9OIHei/OQpj9iu5/8B/g11R74ljkJh3gD7MZfHrmzUdwU2/yaTOzppzP
         NApzdv/mlZxEfHusEmfodGCWEql/73osFMihtsO7Rv+P/unTdMiyUfYHKTqRR/iOYvUP
         MZ1G8Bg0JUaYZDbgp/8be02l2k6UNSAaehUfg1SXordA/q0smPWrKgg/kDTLh0G7U/r4
         l5i3UCrsAJvFxqm/C8cz56R/3UnBCcx36lH6ipiDpNDF+x4xQwj2NZ3m2TMW02fUa73f
         3SfUawZ3DB6zEkweuBSTskzRPjVLEnd1gR9oSAfNA0do+tAwMuol5d44HUexEZe+Cq//
         WM9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=Dyqw3HCSpJOE3kTzeE08yEllmbgy+rYjF7ROKuO8WI4=;
        b=rqlHyA2XrpLbkyXlXNmM1ZxUdMmu2g6Guy/7Gv88dDEChfkp0cd4usEJjhN2kQrluI
         bhAJmmLFVBjdZ1s3xK981hXwKPL1Xm+oBz2iuNKH7P2/kh1YJ/H4GwVMMTcufiuxCobx
         eMp2Xh8PO1d3uH1ubWNVX1ZLynBAKLhchvep1S6+PDFKnCkNWeUhohzYOi+4LXChVf9e
         ZK+YqPOsLwORH4g1LoYKBPj3MqpUZprZnZKEkaBBs919xqpGVLXe51VkToawU/h+gaXt
         v6i3YTmDsHGgZm3vIDCe5FrN+NjltV8rg1nx49I8cg32/Wm2ESKLwFELcoU3bYx9AQGW
         pGEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=edetCLNw;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r11sor9472otd.7.2019.01.10.21.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:52:28 -0800 (PST)
Received-SPF: pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=edetCLNw;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=Dyqw3HCSpJOE3kTzeE08yEllmbgy+rYjF7ROKuO8WI4=;
        b=edetCLNwIi9OUte9bwRp8Fu6kesaxyfuzH738s5y4iBqeBz0hBmRpD73o2wqqro8bs
         rM6VasJGk1pg0Sm/jmaml8/1WNO5fVqnBPV+Pc+0OT+3jL+D2Al1krllLetNWd5/e/4n
         jKeTaM4EVOPks1qfrPW1MBFmkBucbJ66YBQMpW3PF2fqnnR50iE6lLE5sbktV1gLf8Cv
         Hq+8fX8/aDUMw3k1nqGBW3wBTSFQeGgd6aET04PTItg8i3IB4wkSkYirOAAJE3cayQKl
         rmQwPTFJHRAos5wF9R+cnE/c99gW4rrqct+beZpagwvj0IdaBuE2DVN7Z85vQD+naeLo
         Ejgg==
X-Google-Smtp-Source: ALg8bN6plIYg8GtPddHg+I9mdaBY189+breocM8JiUYF7PArdtlZETkfvZ+LsIPhVk1Tt5TQeaBdGwag5V4EV61N38A=
X-Received: by 2002:a9d:39f7:: with SMTP id y110mr8240286otb.240.1547185948051;
 Thu, 10 Jan 2019 21:52:28 -0800 (PST)
MIME-Version: 1.0
From: Baptiste Lepers <baptiste.lepers@gmail.com>
Date: Fri, 11 Jan 2019 16:52:17 +1100
Message-ID: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
Subject: Lock overhead in shrink_inactive_list / Slow page reclamation
To: mgorman@techsingularity.net, akpm@linux-foundation.org, 
	dhowells@redhat.com, linux-mm@kvack.org, hannes@cmpxchg.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

We have a performance issue with the page cache. One of our workload
spends more than 50% of it's time in the lru_locks called by
shrink_inactive_list in mm/vmscan.c.

The workload is simple but stresses the page cache a lot: a big file
is mmaped and multiple threads stream chunks of the file; the chunks
sizes range from a few KB to a few MB. The file is about 1TB and is
stored on a very fast SSD (2.6GB/s bandwidth). Our machine has 64GB of
RAM. We rely on the page cache to cache data, but obviously pages have
to be reclaimed quite often to put new data. The workload is *read
only* so we would expect page reclamation to be fast, but it's not. In
some workloads the page cache only reclaims pages at 500-600MB/s.

We have tried to play with fadvise to speed up page reclamation (e.g.,
using the DONTNEED flag) but that didn't help.

Increasing the value of SWAP_CLUSTER_MAX to 256UL helped (as suggested
here https://lkml.org/lkml/2015/7/6/440), but we are still spending
most of the time waiting for the page cache to reclaim pages.
Increasing the value to more than 256 doesn't help -- the
shrink_inactive_list function is never reclaiming more than a few
hundred pages at a time. (I don't know why, and I'm not sure how to
profile why this is the case, but I'm willing to spend time to debug
the issue if you have ideas.)

Any idea of anything else we could try to speed up page reclamation?

Thanks,
Baptiste.

