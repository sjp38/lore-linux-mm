Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D672AC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DAF92184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DAF92184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370C88E0003; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 353038E0004; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25EBA8E0003; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D85EB8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:22:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so8954811edr.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:22:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=97GfHJsuY7z9DglSQHAcESJQYBbQ6uYaAcoF4hnggAw=;
        b=AxrkyfSxfBKuPz2JYGe7F3Ol2sdiPIM02+MBbjJ1dipCZ5+zRTSvmLzo/dBuNad1L+
         W4sAnDfLotDToRz4F3pubuLHCD5/gkcVR/A7MfbjBAbAv3S5dRDvOMB4jZ5Pk5nN3ZZ2
         fkVOkuTJbG3V9OPkG8GKcdc47lF2SH1g8wgbLwrA1eZ+2QtI/hZ4MLxhdkABW2SBFX/M
         T+S5MgTaFkqWGJNIJGCE9Sgw0MA+LW2qwnCBx4rnxlYjx0LcGxIVrKD+VlYMI7ahUYKY
         GD+/7zYCbY1Ij76mjQys+4+3th9jfdhMaZq1KTuHhfSeT381hdO0CwSL+PmKssDfZ5XB
         q2rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AJcUukdSLztt8MXDMwJay+U+Z3tgbdrofqi8af6fzEEBiqGtbziSRn3a
	8U8xE65t/qTk6XT+3LZQh38YInGouegXpjeKnKjqAheON7DMG4SqrqJ5fUc8GDCrZbsFzJQURl2
	l1NHlM1XJShPPnoLvSkAwu99+o7EvyJhbD8uVthvwcvPYlwu/HJYE4QFoqyxBT/eRbA==
X-Received: by 2002:a17:906:4545:: with SMTP id s5mr24465007ejq.107.1548836559324;
        Wed, 30 Jan 2019 00:22:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN75tALKEKB0R+EGoTUsSdOU/5ukvfpzf78YFpyA4iP/p+mEsxsQbtZLbCyHKO2ba2c+4Ngl
X-Received: by 2002:a17:906:4545:: with SMTP id s5mr24464936ejq.107.1548836557979;
        Wed, 30 Jan 2019 00:22:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836557; cv=none;
        d=google.com; s=arc-20160816;
        b=R/iTRqlbhNAp6xJ9MMfkDwXXIbiCDCdxLYcQxiZYKvXoVlwEHDc1oifA8i+4VkvYjB
         SPhxeKdRAdHCIBWFyYpiDmt51FQZ262E5e4GWuHdthgKiaZBPFqeLpUjftV++RmWmkBo
         5aUBeHjLvLUaeJIWQly3iai7PvL2E5S8UFSlFuVrWL81IsXjz4oZLsYP/TeBfUSHYLL0
         E36K73BxZjSTffwxkw17qJGJcwdEcP7hJNgXGbwW9lUo2s1ceLnpW+NXAi6mFRTuVycm
         xShwOd8syIk/NaBCd4+i3A9vBQu8XkwQEn4S9plp+GEE+vTyWzj09wcA+XqCPF8M+iAa
         pezQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=97GfHJsuY7z9DglSQHAcESJQYBbQ6uYaAcoF4hnggAw=;
        b=sGVUuuEDpdLvWABPtwTnV7M5t0M0a7+uCCQicR4kSVY+jtn3RTdfr+lOFU+MDTnQ57
         LB3VcPv5TblQEk1SWhF0hN9/cB8QaZAbgqPe9ajD2uC2UqVeMnJNUEkR0U1pYHs07sC/
         TynbwiPrig1OoqC00OkujlVBrmajHK7I+BkKYRrU4VHakyVvoDFhX9c4yLGhxjQQEqlz
         CNeqRMgnjOM6JLDtOruRNSEgpLFgJ45mZS13esqL5ll/BbzcygT+5krX1U7l2gN5n6PT
         OU+7t7j6nhciM21nzbXGvmbqEKJ74dKWl94UGEKMMSxGOOqRuH1/c1ikiinV/eEBeqC3
         wTHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr21-v6si587002ejb.301.2019.01.30.00.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:22:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DE5C6B0DB;
	Wed, 30 Jan 2019 08:22:36 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	x86@kernel.org,
	linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com,
	sstabellini@kernel.org,
	hpa@zytor.com,
	tglx@linutronix.de,
	mingo@redhat.com,
	bp@alien8.de,
	Juergen Gross <jgross@suse.com>
Subject: [PATCH v2 0/2] x86: respect memory size limits
Date: Wed, 30 Jan 2019 09:22:31 +0100
Message-Id: <20190130082233.23840-1-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On a customer system running Xen a boot problem was observed due to
the kernel not respecting the memory size limit imposed by the Xen
hypervisor.

During analysis I found the same problem should be able to occur on
bare metal in case the memory would be limited via the "mem=" boot
parameter.

The system this problem has been observed on has tons of memory
added via PCI. So while in the E820 map the not to be used memory has
been wiped out the additional PCI memory is detected during ACPI scan
and it is added via __add_memory().

This small series tries to repair the issue by testing the imposed
memory limit during the memory hotplug process and refusing to add it
in case the limit is being violated.

I've chosen to refuse adding the complete memory chunk in case the
limit is reached instead of adding only some of the memory, as I
thought this would result in less problems (e.g. avoiding to add
only parts of a 128MB memory bar which might be difficult to remove
later).

Changes in V2:
- patch 1: set initial allowed size to U64_MAX instead -1
- patch 2: set initial allowed size to end of E820 RAM

Juergen Gross (2):
  x86: respect memory size limiting via mem= parameter
  x86/xen: dont add memory above max allowed allocation

 arch/x86/kernel/e820.c         |  5 +++++
 arch/x86/xen/setup.c           | 10 ++++++++++
 drivers/xen/xen-balloon.c      |  6 ++++++
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            |  6 ++++++
 5 files changed, 29 insertions(+)

-- 
2.16.4

