Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E31DDC10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD853218D2
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD853218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52E6B6B0284; Wed, 10 Apr 2019 07:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B91B6B0287; Wed, 10 Apr 2019 07:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BBDB6B0288; Wed, 10 Apr 2019 07:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D70226B0284
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:06:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z9so1185064wrn.21
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:06:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=hgUYKLZli5yphNqQuanQ8lMvCN3LTjThq/hkCT3u9OU=;
        b=Saom9QY9u2aitX3lWvB0QuQGGW+vakV6tKU5oy83Tko3E5YTkUEnaFpivYNVUnn7+B
         LkptNV2m617kAM9XG0HevQjy0bbYvZ5djFfk3i5eKc/Q0BbWtcyj5+KffdxrzqwncdY5
         YsU19uQkJsTlJMzvUUoPw7h7y0ReBC5mGDKvz6CU+PDqkMn+qjAcNFY0B6Tyb/oCK9XH
         2Coehw0VG05vZThxD175acaH3jm8rssg3t145EBozIJv4RXKKpkNGD/1RjMDNq+84uKc
         PCyAsUUB7jNJD5u9hpdQe3iZQ14fXNFf+f3HpJUOJsxHCGHWJMhES6z2ZbZ4gIuLgyoQ
         Av4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXPVlvYDgizuuNAZEAC5X4VSQP6dvPxV1mSxFAo6WpBO2tTbDQW
	p1UpkLqNtiqegJgZDcrv/OC49HGKxcgPsUS40bH2KSaT+8Ndku14HQ7e3iRls/C9GEna9UsjEI9
	qnCUqaN57ZfigndAQw4+0CmSciKm/pcpRmHeuCu+nt18KNXV4yadNgnwz2gew0DwpuA==
X-Received: by 2002:a05:6000:124a:: with SMTP id j10mr27975443wrx.24.1554894372428;
        Wed, 10 Apr 2019 04:06:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKSEbZNw85YEtn+3hA6ok9OtA+bD0d5+24W0DJoIoSuKZwSDTr9V9qwHKMma8f0VyGBwj7
X-Received: by 2002:a05:6000:124a:: with SMTP id j10mr27975397wrx.24.1554894371731;
        Wed, 10 Apr 2019 04:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894371; cv=none;
        d=google.com; s=arc-20160816;
        b=fjNLcw5JQMYQFqYRKj4eTxHJrxDpS7hSNBiz1yWDY/7CzY/2SEh8f9tbmkhTLo5Q2/
         +cxkBD8IZ+wwL57xjjQIAcOGTKisAWGZ6Z++63hPl2HB9scoKqdnSw/L9WG3Iq3W+VfC
         pb1DRcqb7Ar4p+iTC+QfATZ89ls0sH6Zaxxv5m2GVyB95ysfs5cgfPh3Xwfw2aHAhnwF
         pXKVhx2pKMnGKclnw0eiqvQpj2cRap4A8UPO0fC52CU0xnJxYu+rAYZ2U0AOD7IaNz/O
         UQAc2qdenFDiv1XEhM1XpvDvXJ/Io2QpwgR5xoMeUW7OMDPqeZW3oyN5cly4aQl1+BdP
         epfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=hgUYKLZli5yphNqQuanQ8lMvCN3LTjThq/hkCT3u9OU=;
        b=cQbAtazPQmoUuPEY49FLVDXP183Sazi/99j2qcQVVkdGtEUTZlQrFZ86pU8Wxcn8yo
         u3rgv+N7l7ZMBDnjLDT0w73mpovTJ64Ynd694PIX44utZUYJvhtA8iXf2lcpx9ojJmY3
         aAByt+z+jNhPCxS0PT5Id41XChhriueaqGEhFfyyeT4i+YtE3dHQALkvMN3CXwoDu3de
         q7/XITMGffZcoLveFX3nmVUT96XO2zsrMHQZBkBQGoe/8+hDE65zl9ZBsOgg2WfdwkXM
         AVSv62SppGyV2v9c7h7ncu3Ypy0d94hDX11pEZHP6PY7tpEaBgemdKUVXqWDWnKnPseU
         EhZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x5si18109793wrd.204.2019.04.10.04.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:06:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB2z-00054D-Jd; Wed, 10 Apr 2019 13:05:41 +0200
Message-Id: <20190410103644.661974663@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:06 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>
Subject: [RFC patch 12/41] mm/page_owner: Remove the ULONG_MAX stack trace
 hackery
References: <20190410102754.387743324@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No architecture terminates the stack trace with ULONG_MAX anymore. Remove
the cruft.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_owner.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -148,9 +148,6 @@ static noinline depot_stack_handle_t sav
 	depot_stack_handle_t handle;
 
 	save_stack_trace(&trace);
-	if (trace.nr_entries != 0 &&
-	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
-		trace.nr_entries--;
 
 	/*
 	 * We need to check recursion here because our request to stackdepot


