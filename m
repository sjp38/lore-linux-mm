Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7719AC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3904B20883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3904B20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19A76B0006; Tue,  9 Apr 2019 06:02:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC95A6B0007; Tue,  9 Apr 2019 06:02:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 991A76B000D; Tue,  9 Apr 2019 06:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79AB06B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:02:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id y64so14116601qka.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=bOjlbK5Ew1jwsfpeHVKx+Tr2HBLZO6aji5Sk2gVCam0=;
        b=RrBP0/2Vr1xM2szFbejDNxneR+GZzKEYwB0nVnre7JBlZ768XqaPRtkE7DfgUELbZg
         0I/Ednl4GJig5tJSuvrsD4jWz6mcqTidxqSAlN98qx/cEJ2DQ/7OMKX3TB+rA65Ha3/5
         W8DMNpxbbnRaqaur8/TGYYjulSe0ffCSh7JpcNKMIk9JbuSpxgvd1Sbj/8Ynd+Hn7yBl
         J4Y3Q7S651n4ocFYTMuSIHQlMDVzK6MkKVYvlWf+3NfInNEUKHlZI5ugxd9ETmUx+//f
         OMD3ZUUmelRWQTH8uzwcci9xIlP4sSQOUDQiOlcJOPIXMWTMoplwkbCe4UJe88FIlND3
         POGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXY9AlWsvUIn9A667Y2snNGz849GGNsrJmUOjxnCkzJ02DHS0gj
	FMP623ebs9evVzeN06rPI3j3bphK46wo1TdMusO8OikrsbjSnZhjWKKACHcFy4oCNRciH6835QG
	sN6TfKJEmfzvUkwl0wICSZ/yPBBU4M/hePFky0CFACbAHBNkEL1i4azbAjbqtaIEzNg==
X-Received: by 2002:ac8:1833:: with SMTP id q48mr29057860qtj.133.1554804123254;
        Tue, 09 Apr 2019 03:02:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoCzl6SgyuWopR9OzXi3DYisobgSyDjGp9C5LxUblsUSD7HzWGXo616O4Q9uqZAVsQHrby
X-Received: by 2002:ac8:1833:: with SMTP id q48mr29057791qtj.133.1554804122471;
        Tue, 09 Apr 2019 03:02:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554804122; cv=none;
        d=google.com; s=arc-20160816;
        b=rxZSOH7VjE7Csbb5HnWcdHNQHk+wQpVRAVaHqhag3gedsfstu2mUVBMEBtwV/vX/2N
         GSM39iodOJY4wWuv2EsQcXMo542G2W1SJ/zDZ/jJwicwkpFlaATOgjFEeNvLGFO5d1WW
         f/+V/Y4oca1Db9ai1zXs65IXvOsyjD1IkAVr2YwSsgEtRi7BCoaBCNLCCKW9mFfr1jjW
         yMLXSsnZEfbuje9Cxy8gV+mgge86dLrtt3KRJRR/Gxs7z39GYBEVbwUTkEsWCfysy4f0
         bzrokfHC0/s3DucX3JUyOg4txfO8UWym4XpP6OnqRGAKkpFKlmUcJhnPz8n75FsOCye1
         XycQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=bOjlbK5Ew1jwsfpeHVKx+Tr2HBLZO6aji5Sk2gVCam0=;
        b=CJxwAOjC0eBHezEDtpchiOJdtOTb0B3TldJ674WZ/jVy8qCgMP3slNptF88sXOb5CO
         FkNNGqOXfmXoV1/jLFv7yLs/znhC2sKaw8i4d/4wz7XkwuYq47LFalOU/4yHj15qtLr0
         F0H+fSnhwfV7/u2vi26iosqY5qBacwzv6kufNkPjpIxpeYeofJxFSmHVbqy7RkLHa3TB
         Cc+etF+CCLZKEF9ezv0k6NV5nJr2bqUCM6G/ALyrzBIBbdAnn8ZqWW/bRqdAbt4OAB/Z
         alpo19zCcOfX+tOXnuPiWCdLS96GC/BdXDRT/0RD5FEMUpyYVkoyVnCw/0VVC+SN47WZ
         CYyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o7si4692768qkg.268.2019.04.09.03.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:02:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05A59307D98D;
	Tue,  9 Apr 2019 10:02:00 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0DF0D5D71E;
	Tue,  9 Apr 2019 10:01:48 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	Arun KS <arunks@codeaurora.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mathieu Malaterre <malat@debian.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh@kernel.org>,
	Stefan Agner <stefan@agner.ch>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH v1 0/4] mm/memory_hotplug: Better error handling when removing memory
Date: Tue,  9 Apr 2019 12:01:44 +0200
Message-Id: <20190409100148.24703-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 09 Apr 2019 10:02:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Error handling when removing memory is somewhat messed up right now. Some
errors result in warnings, others are completely ignored. Memory unplug
code can essentially not deal with errors properly as of now.
remove_memory() will never fail.

We have basically two choices:
1. Allow arch_remov_memory() and friends to fail, propagating errors via
   remove_memory(). Might be problematic (e.g. DIMMs consisting of multiple
   pieces added/removed separately).
2. Don't allow the functions to fail, handling errors in a nicer way.

It seems like most errors that can theoretically happen are really corner
cases and mostly theoretical (e.g. "section not valid"). However e.g.
aborting removal of sections while all callers simply continue in case of
errors is not nice.

If we can gurantee that removal of memory always works (and WARN/skip in
case of theoretical errors so we can figure out what is going on), we can
go ahead and implement better error handling when adding memory.

E.g. via add_memory():

arch_add_memory()
ret = do_stuff()
if (ret) {
	arch_remove_memory();
	goto error;
}

Handling here that arch_remove_memory() might fail is basically impossible.
So I suggest, let's avoid reporting errors while removing memory, warning
on theoretical errors instead and continuing instead of aborting.

Compile-tested on x86-64, powerpc, s390x. Tested on x86-64 with DIMMs.
Based on git://git.cmpxchg.org/linux-mmots.git

David Hildenbrand (4):
  mm/memory_hotplug: Release memory resource after arch_remove_memory()
  mm/memory_hotplug: Make unregister_memory_section() never fail
  mm/memory_hotplug: Make __remove_section() never fail
  mm/memory_hotplug: Make __remove_pages() and arch_remove_memory()
    never fail

 arch/ia64/mm/init.c            | 11 ++----
 arch/powerpc/mm/mem.c          | 11 +++---
 arch/s390/mm/init.c            |  5 +--
 arch/sh/mm/init.c              | 11 ++----
 arch/x86/mm/init_32.c          |  5 +--
 arch/x86/mm/init_64.c          | 10 ++----
 drivers/base/memory.c          | 16 +++------
 include/linux/memory.h         |  2 +-
 include/linux/memory_hotplug.h |  8 ++---
 mm/memory_hotplug.c            | 63 +++++++++++++++++-----------------
 10 files changed, 60 insertions(+), 82 deletions(-)

-- 
2.17.2

