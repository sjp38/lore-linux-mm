Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E713C04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:40:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C46972082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:40:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="c4eMVd1c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C46972082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57B556B000C; Wed, 15 May 2019 04:40:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 505A46B000D; Wed, 15 May 2019 04:40:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CCF56B000E; Wed, 15 May 2019 04:40:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id C95936B000C
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:40:57 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id f15so432571lfc.10
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:40:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=PqVaSFiBytC8hxBsEh/HgINdW7HiuF2nkdZ+Xr3sRJM=;
        b=Q5mdCx5ayLvbeGbbyKRnJmhcAeAx7lZFmshPYQ9UQG//reXFFa8tm/3wWfHu9Ie9x3
         XWhAKtKjlbodPbHT3js5Rqk1QZT5u7PIAcCP/MTM8Q00FK1p/hvA2XCuG7J7wh7LNh5U
         WMK+UrO/CoLfdrWGKW5R/GxvepucEab6mAwfFCzErQ7g6kIweHmA3IPZkbRWijdSqWbY
         8rnDjVURtBF67fRlW7CakeqvWyRn9gW9LICdQTUO5WgwK+XPDM0aY79TAyzSLNlr4Qv8
         3StLfGP9NBMSJ92v60Is0z55GpyyvAMvCcVs8sRn0pjE4nLqQb+TTNOsHj1gcVdulYi/
         YgCA==
X-Gm-Message-State: APjAAAUqiykWdsZOSKZpLI/HhBsZUa7imQRm2u7D+IdzHaY8GG4WCmrY
	sUiSKl4tQ+uZ0wYVVD2BjzGnKbyEMKH9DroiNBKgcIyNx5RlIH4P9nu1N6RxBHU9xpM3cDbqp6g
	gxgz8fgOELGeAspbnfqjTNC//CwlxRA3Stz+viAdny0PWRhW+/ksIrx75aoEhuZpklw==
X-Received: by 2002:a2e:5c08:: with SMTP id q8mr4733481ljb.113.1557909657162;
        Wed, 15 May 2019 01:40:57 -0700 (PDT)
X-Received: by 2002:a2e:5c08:: with SMTP id q8mr4733395ljb.113.1557909655407;
        Wed, 15 May 2019 01:40:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909655; cv=none;
        d=google.com; s=arc-20160816;
        b=mb5kTHoMDv3Oj5HlAOzuuFYGxzcWaaIQYmQiI9ckspJhOSU16WeN1vk3LR5XA667LT
         y8llj3aRIivqc64l8x6qTq3Ye0xIPFZuQL3f79eupB5W16TnUbdyo0syvb825p0A3xBK
         y0RQUGHLM3JyUeOziyYHeLs6vrf3g0WBdea8rd91IXmCBRlDZvFUOQMW2mWyDXtErA4+
         LN2I/LxWInhaINPxcMOa9J8tkaiXlNt8imyEGUG+yiWsJU+FbZirzVI19xicEd0QkKJV
         QU89JW7Rdh5O4h5N+5auegm0xYkL5BiWv+QqQ16kmI0C0DUSvGwwu2SCUYZ0a9wm+KwT
         ojSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=PqVaSFiBytC8hxBsEh/HgINdW7HiuF2nkdZ+Xr3sRJM=;
        b=ar+uot0/RfTIhLqUxHWtVgM78m1RlbuQpJ8khN5yjEkIErN/T6eKg1hGLVlOLvVIYK
         KyVV90RomzOdzKzaRpph3jZTFkt8uH6eNIzsviCVuS+6WLvADJz9aXa9T3z5Cb0rqPUh
         3Aw8/g/AHEPdPq9HIA2VDnfM+/VnIzq3MvxhEjoho0O2apZe583rjkfrMDEYcvJ8ExR/
         bXnh8c7TAXpLIXGWzIq8Xo23mDPCgqrGKzLrCsS4e0QNBnCaxxYKqI30T/HjtdxewTks
         Z8USSmRK8iAbu062HZp7mO3hobjGCq04Rx0VZGbv0mvs//VddYOeav53jQAoczplk+Hs
         R0Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=c4eMVd1c;
       spf=pass (google.com: domain of naresh.kamboju@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=naresh.kamboju@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y17sor399921lfh.61.2019.05.15.01.40.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 01:40:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of naresh.kamboju@linaro.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=c4eMVd1c;
       spf=pass (google.com: domain of naresh.kamboju@linaro.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=naresh.kamboju@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=PqVaSFiBytC8hxBsEh/HgINdW7HiuF2nkdZ+Xr3sRJM=;
        b=c4eMVd1cLxlB6SJBmNhemOrHGlx22bRWlhjGFOgNaLhbLW2OsPnJ6q7IN/0qHO2SJT
         44NH8SW7Cz7C3NbkZ6LUVyuc+HzNnulv1amtnBP+4BzX65YCeVqIiFPthbsIvGNRastI
         FbjiJSRIsNnOy55OzOM24lwDTwQ8e3guvD/twvzX8/U23YRpw/0O0FdUM5g8ol8rvtGT
         3HQfxeXNsLpmFjaOI0s2beybpvYsZWr56AL1iTqZnKWFCOtzAIRlXYsgw/i9aL/6NEPD
         g7GWfCO0vCdWKEMkUAxLxifdzh0t3jxTgaNvygX4vDQBbW/QJM0RreiOZzIYruK6B9fL
         hGdA==
X-Google-Smtp-Source: APXvYqz27fihyYyeqJzcm9uZcyrM35iaJPBOLqtP38PCvZvb3HdahvBJTwe31L0dHMb3DcwxQ1okZ20YuVymiVG6A6k=
X-Received: by 2002:a19:6b0e:: with SMTP id d14mr16922584lfa.137.1557909654616;
 Wed, 15 May 2019 01:40:54 -0700 (PDT)
MIME-Version: 1.0
From: Naresh Kamboju <naresh.kamboju@linaro.org>
Date: Wed, 15 May 2019 14:10:43 +0530
Message-ID: <CA+G9fYu254sYc77jOVifOmxrd_jNmr4wNHTrqnW54a8F=EQZ6Q@mail.gmail.com>
Subject: LTP: mm: overcommit_memory01, 03...06 failed
To: ltp@lists.linux.it, linux-mm@kvack.org
Cc: open list <linux-kernel@vger.kernel.org>, Jan Stancek <jstancek@redhat.com>, 
	lkft-triage@lists.linaro.org, dengke.du@windriver.com, petr.vorel@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ltp-mm-tests failed on Linux mainline kernel  5.1.0,
  * overcommit_memory01 overcommit_memory
  * overcommit_memory03 overcommit_memory -R 30
  * overcommit_memory04 overcommit_memory -R 80
  * overcommit_memory05 overcommit_memory -R 100
  * overcommit_memory06 overcommit_memory -R 200

mem.c:814: INFO: set overcommit_memory to 0
overcommit_memory.c:185: INFO: malloc 8094844 kB successfully
overcommit_memory.c:204: PASS: alloc passed as expected
overcommit_memory.c:189: INFO: malloc 32379376 kB failed
overcommit_memory.c:210: PASS: alloc failed as expected
overcommit_memory.c:185: INFO: malloc 16360216 kB successfully
overcommit_memory.c:212: FAIL: alloc passed, expected to fail

Failed test log,
https://lkft.validation.linaro.org/scheduler/job/726417#L22852

LTP version 20190115

Test case link,
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/tunable/overcommit_memory.c#L212

First bad commit:
git branch master
git commit e0654264c4806dc436b291294a0fbf9be7571ab6
git describe v5.1-10706-ge0654264c480
git repo https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Last good commit:
git branch master
git commit 7e9890a3500d95c01511a4c45b7e7192dfa47ae2
git describe v5.1-10326-g7e9890a3500d
git repo https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Best regards
Naresh Kamboju

