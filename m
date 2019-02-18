Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB88FC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:34:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98FD32089F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:34:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98FD32089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=angband.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38A698E0004; Mon, 18 Feb 2019 08:34:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339628E0002; Mon, 18 Feb 2019 08:34:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2509F8E0004; Mon, 18 Feb 2019 08:34:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5A838E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:34:27 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id b9so7848722wrw.14
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:34:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=hcqmhSFLWS4InaULMDSTMjMXIU8QBoJOtQge6Oi+cko=;
        b=UHzYvzBhh9/qp+vL6XWTWyp9L500LpT8B4VrHtPx1SIFHDPEEJlJJ770maUHG2vYoT
         sUXLrdB9LojCRlfJFvmJ/Cxa81x80WU233vJty4qDPxMgL/0FO39HHkyrNyVlWIJhfWA
         7cZjPhzd0vxR3va+jCCOkqkfy/fl2DYixYOjod2z+GW6LP/WZQrj7ulP3MEKTi44m033
         8bFMdH8DmAlDmgMAVFRzfMGXBFLax0mOTtR1ezCipXV692s0aby3HBTDoyMVbQcANz8C
         okFTNAfcfXtcykIfmmzbtL6jXffcl5SD5PMsiNCgPVnHQE5UuEkxnxL1rIdcUvzO/7iu
         Vvkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
X-Gm-Message-State: AHQUAuZr2c2rMMbnuICnu5r8lFzXouSvnedRFBYKL6XOyrYPfgbUQhUp
	yG1fOY9P5MfMiOKC0oDTu2z7ak8vMHudpBobXP3Ba3eLljj74ygI///yxA+zEig3HhX5VPMR1EZ
	K41zfAbcbWkXHWtUqzTmCE8ClogpolTyJQjI2bTmD4X8Pk+4QOpxlAJVSWKT/yWW+kQ==
X-Received: by 2002:a5d:4cd1:: with SMTP id c17mr15824288wrt.229.1550496867326;
        Mon, 18 Feb 2019 05:34:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmfAFcG51LG3CsVmxtbSRbz/k0GOvEE6iWJWsXpd8pNq9ixYOEtVVi73/flvlw1z1RHog7
X-Received: by 2002:a5d:4cd1:: with SMTP id c17mr15824250wrt.229.1550496866318;
        Mon, 18 Feb 2019 05:34:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550496866; cv=none;
        d=google.com; s=arc-20160816;
        b=ez/iVGiYzd2uFDeS+afqMaXIFsaDLX97oSghlTXXhx0L7moIVKJ+bn3NJhEugeKFI0
         i+JQNwRiw5oJYscUYd6UfKAnl4wOhpsab3Ps1BkqhDFQc2P/KhrxklxMYlky0uKl5ox4
         mG7Fpfv8tm38AJ+2gEulRvT/giUwdhjZiUVgkgpM4qj+zShbqHDePHwsldd4T6cechiH
         Cpokkc95tB30MzA1ZWBaA/JbvaDB+nA0NTHVRITpHG6T2V/Czctw17lltL4n3BEbIZz7
         HDQ82FAUZgpWlv0x5HWBtXzTBRs3Y1TjyweymcZzLUXmPcRJkzFNvOBxIYeJkHzc8C13
         MHcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=hcqmhSFLWS4InaULMDSTMjMXIU8QBoJOtQge6Oi+cko=;
        b=iG6vX5hoaJWNhcrs+xybry0qkOMNypu16G2RSp1HgCDFPzhrAOP4yI19mE39W8j1YD
         R8SEBYj0KhlXJm/zmpPTywkS308LTO4fuOnhNljSqkwPQLIayNG3+y6zyp+2fOcaQUIu
         IaAIpc/VH5sAf7JiXN3czuZpo7ZebQXr5UeqQKDEVBErKq3H2HGXft403F1LF+VdrzL6
         OnDT1mdnlXVYPoTu/Y07F6OCHLm4XRsRhnnlU/xnfKffhmZLYAYKtEJ69DA/ulrHvj9B
         NPh7nj6hKgx1ydADbmBXPt9xAiIoINDGotmTMCXaPCdpTrpLpwZaNzq2TNKFTptF07Fu
         hMlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id c17si9428647wre.152.2019.02.18.05.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 05:34:26 -0800 (PST)
Received-SPF: pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) client-ip=2001:41d0:602:dbe::8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from kilobyte by tartarus.angband.pl with local (Exim 4.89)
	(envelope-from <kilobyte@angband.pl>)
	id 1gvj3v-0006jN-Ge; Mon, 18 Feb 2019 14:34:23 +0100
Date: Mon, 18 Feb 2019 14:34:23 +0100
From: Adam Borowski <kilobyte@angband.pl>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@intel.com>
Subject: tmpfs fails fallocate(more than DRAM)
Message-ID: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
X-Junkbait: aaron@angband.pl, zzyx@angband.pl
User-Agent: NeoMutt/20170113 (1.7.2)
X-SA-Exim-Connect-IP: <locally generated>
X-SA-Exim-Mail-From: kilobyte@angband.pl
X-SA-Exim-Scanned: No (on tartarus.angband.pl); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001518, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
There's something that looks like a bug in tmpfs' implementation of
fallocate.  If you try to fallocate more than the available DRAM (yet
with plenty of swap space), it will evict everything swappable out
then fail, undoing all the work done so far first.

The returned error is ENOMEM rather than POSIX mandated ENOSPC (for
posix_allocate(), but our documentation doesn't mention ENOMEM for
Linux-specific fallocate() either).

Doing the same allocation in multiple calls -- be it via non-overlapping
calls or even with same offset but increasing len -- works as expected.

An example:
Machine has 32GB RAM, minus 4GB memmapped as fake pmem.  No big tasks
(X, some shells, browser, ...).  Run ｢while :;do free -m;done｣ on another
terminal, then:

# mount -osize=64G -t tmpfs none /mnt/vol1
# chown you /mnt/vol1
$ cd /mnt/vol1
$ fallocate -l 32G foo
fallocate: fallocate failed: Cannot allocate memory
$ fallocate -l 28G foo
fallocate: fallocate failed: Cannot allocate memory
$ fallocate -l 27G foo
fallocate: fallocate failed: Cannot allocate memory
$ fallocate -l 26G foo
$ fallocate -l 52G foo

It takes a few seconds for the allocation to succeed, then a couple for it
to be torn down if it fails.  More if it has to writeout the zeroes it
allocated in the previous call.

This raises multiple questions:
* why would fallocate bother to prefault the memory instead of just
  reserving it?  We want to kill overcommit, but reserving swap is as good
  -- if there's memory pressure, our big allocation will be evicted anyway.
* why does it insist on doing everything in one piece?  Biggest chunk I
  see to be beneficial is 1G (for hugepages).
* when it fails, why does it undo the work done so far?  This can matter
  for other reasons, such as EINTR -- and fallocate isn't expected to be
  atomic anyway.
* if I'm wrong and atomicity+prefaulting are desired, why does fallocate
  forces just the delta (pages not yet allocated) to reside in core, rather
  than the entire requested range?

Thus, I believe fallocate on tmpfs should behave consistently with other
filesystems and succeed unless we run into ENOSPC.

Am I missing something?


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀
⣾⠁⢠⠒⠀⣿⡁
⢿⡄⠘⠷⠚⠋⠀ Have you accepted Khorne as your lord and saviour?
⠈⠳⣄⠀⠀⠀⠀

