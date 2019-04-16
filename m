Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6146BC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:10:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B6BF223D5
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:10:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B6BF223D5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FAE76B029E; Tue, 16 Apr 2019 10:10:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AAC06B02A0; Tue, 16 Apr 2019 10:10:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89A6A6B02A1; Tue, 16 Apr 2019 10:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39EF16B029E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:10:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so19115713wrs.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:10:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=bcwtsG3AsTGo9tev0nV+FZQAPz0TKizWn2+evyQlQVQ=;
        b=QRwz/cGNeSBrFttXNPxyeIDXaZ4BKsE37gxlpt21gedaHJ99OaSbLgZuq7tc1UaTGa
         kyLxcFSsU/zr0Ex/bO+q6fnoqU68AXnXwOcdXAUNTrqsAmAJKt3asdM2R3mVsJJK7iR8
         X7LBbe+Jd3ZiF9hakUbhrP+LnfN3eCrm+o8J1xdBNnWhyHs81NGERwjjUt1RzaxXNafB
         GqEgv5C72Xd8F14GphNX5R+omig0tuBRjUt7XODWPlaptHXzstUEIDNieOfyusf/5D47
         ZsX3Q1GWox5GJht9ovP7qudpKxqSyxSPRVFcCy1lUvUj5ytV7e/eD0fh3xNQGUDg2wd6
         r3AA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV9xgGeIHA2x0yrLVfXwmw/27NnLk6jHDFoDARCfP4tK69MYpNe
	RimEyM3C6br8Fb2Yf6Wnq8nhmBENNrys2djr+rurqg+K7HTP9gwKM3mswO6ojTU3ii0SR5Q+wKA
	gtutuetmk2cttHWSU7R4UaaUikRqovOdiEV2Ku58mRBN4ak/OVmuZOqQ549Nj2ehvkA==
X-Received: by 2002:adf:f80c:: with SMTP id s12mr44765564wrp.72.1555423837577;
        Tue, 16 Apr 2019 07:10:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzyEC+mcckMD/kK6vxg/zwzP2beOMq3NejC99jb8KJXsZVGUjq4PhBUJjN9qwa2z2s/Q/f
X-Received: by 2002:adf:f80c:: with SMTP id s12mr44765478wrp.72.1555423836412;
        Tue, 16 Apr 2019 07:10:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555423836; cv=none;
        d=google.com; s=arc-20160816;
        b=ZODAogiSr4pKkKqNSZshvxheDU5FqgKgmZYY0moPsjF3GKBVBXXQQjAaoroH15WVeI
         tw9PJ6uwTM3BStVDh03DbDZUfNsD5o/uYmwScN81T6KzTHie9ZRuc/rbpZ8K4AVowDrN
         6gvlOwBGvzrFnPuAa7TQoaYfYBD3a+qjFV5IRK3SAzHJXtEzQXJUovIy4XE/fNvLoLWx
         XISAUnC47yakha1f3mwHX7WHY5+S/7SqBMiPsTIG6R+0gv8MFodM89cAyMJ/fu8KdRfk
         2x46L9T3jdVz7/sVTSl4enabwyGrYOCs/tVfO41ui6lZvuNf4jfvMEupT88BVz5ise5+
         Z0UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=bcwtsG3AsTGo9tev0nV+FZQAPz0TKizWn2+evyQlQVQ=;
        b=0x/iXrnbjui/Rtn/+/gsdYqVm9bXkiKoWUZH3cXvY803JlCZ6YaeYxP9lZRIoZWMAD
         ePk2F8X6keV+1RgaM3pDpK6Zhj+Xvi5Ly25eg7b+wYZfLOiD1202e/QmEkDZSOQlf404
         06XLhR+KzUfNPkCuvhXq0wmYl5IiRoRQXXUdFcpCb/4/A2JeY+qBegqMqZmVuMb0oDyv
         K8wsxjIGNtNZH4kOeackY3xee42fqVJkKNJFSuYDZINJR8gOJJDBtPIPwA8EDOhMmxsx
         pm5vCxlkNczxoQyjSPd6PKztiqrEfVxU9++M+vqu1ivWx3Atwbxg+SgURQIVvr0zUztk
         KWhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j19si12808418wmh.46.2019.04.16.07.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 07:10:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGOn3-00036D-Gl; Tue, 16 Apr 2019 16:10:25 +0200
Date: Tue, 16 Apr 2019 16:10:25 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Vlastimil Babka <vbabka@suse.cz>
cc: Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
    David Rientjes <rientjes@google.com>
Subject: [patch V5 01/32] mm/slab: Remove broken stack trace storage
In-Reply-To: <612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz>
Message-ID: <alpine.DEB.2.21.1904161608570.1685@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de> <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble> <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de> <20190415161657.2zwboghblj5ducux@treble> <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com> <alpine.DEB.2.21.1904152320540.1806@nanos.tec.linutronix.de>
 <612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kstack_end() is broken on interrupt stacks as they are not guaranteed to be
sized THREAD_SIZE and THREAD_SIZE aligned.

As SLAB seems not to be used much with debugging enabled and might just go
away completely according to:

  https://lkml.kernel.org/r/612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz

just remove the bogus code instead of trying to fix it.

Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
---
V5: Remove the cruft.
V4: Make it actually work
V2: Made the code simpler to understand (Andy)
---
 mm/slab.c |   22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1470,33 +1470,17 @@ static bool is_debug_pagealloc_cache(str
 static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
 			    unsigned long caller)
 {
-	int size = cachep->object_size;
+	int size = cachep->object_size / sizeof(unsigned long);
 
 	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
 
-	if (size < 5 * sizeof(unsigned long))
+	if (size < 4)
 		return;
 
 	*addr++ = 0x12345678;
 	*addr++ = caller;
 	*addr++ = smp_processor_id();
-	size -= 3 * sizeof(unsigned long);
-	{
-		unsigned long *sptr = &caller;
-		unsigned long svalue;
-
-		while (!kstack_end(sptr)) {
-			svalue = *sptr++;
-			if (kernel_text_address(svalue)) {
-				*addr++ = svalue;
-				size -= sizeof(unsigned long);
-				if (size <= sizeof(unsigned long))
-					break;
-			}
-		}
-
-	}
-	*addr++ = 0x87654321;
+	*addr = 0x87654321;
 }
 
 static void slab_kernel_map(struct kmem_cache *cachep, void *objp,

