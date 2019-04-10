Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0E5DC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F58221915
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F58221915
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E526A6B027A; Wed, 10 Apr 2019 07:05:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDBBA6B027C; Wed, 10 Apr 2019 07:05:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC9606B027D; Wed, 10 Apr 2019 07:05:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84E616B027A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:05:48 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so1219272wrs.1
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:05:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=8bk9z1Ja4+T6AzhJsl417UlQDfrKqoRXML8B0kjTIwM=;
        b=kD0WazWmuJ3vem9Za81mo1NSb3PM48mwsU5hVJ1sfak+i3leC7733Vbz2Q2tF+Wy3U
         pQzj8LC2vm5CHYrb3AEQEskI70wdNBuxuF/CFDFarE6+L0xA0c2eqFLiht3DcMEbrOJJ
         k/j0E4rAn9LmstnQ2mBWqaiEawwtadNtBCiV5ovnyV5fAsIAH7dAn14V8sg1MUCMLxnq
         Ze8PAvVUsbO/8nzQZ+XCFXQu5bqHDLM3HDd3XMDqP/F4AUUbTlmZBJnPqrWDXBhXkQFP
         CE1IhfFslnYtrewcLqlsExkorqXdXlVVPSLh1defszvluWvrwRtYgz8EWOwtmWeMWKXM
         3iKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXKsI7NtW6Vh+YcwTs8PJ6eCPlX0nrYn+nKSE1KX019kaMYFPXJ
	QNAYxSNkvbCFvWo7jgTEx1mjQ/LiYo4p5Lu0bqy698lqiNwo+qaAZkonMd1XquboYI72LM9vgp+
	GkhAlAdg5fB8B3kix4Bpt7ui9/7mbm8v0GmwOu3/BzyQzX8z8lSTBSKicYBF08R+mAQ==
X-Received: by 2002:a1c:f909:: with SMTP id x9mr2538488wmh.18.1554894347947;
        Wed, 10 Apr 2019 04:05:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ3IcPSXbV7uzmIoLQhBXc7/knsJZrfhRvoIV0qJDCLHAk9zpVneoYQDfMCZRefigyItaI
X-Received: by 2002:a1c:f909:: with SMTP id x9mr2538423wmh.18.1554894346978;
        Wed, 10 Apr 2019 04:05:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894346; cv=none;
        d=google.com; s=arc-20160816;
        b=GeoFU1KIgTBii23EGi95/XMvWrN8wcPEPMD7ykJnvOq6eGxJRugGCIS96Q4LRm6O7F
         6wOkb4FCXOqkMd6A9PFJ762UOgMZ52sW8IEIYM9um6XMhGhUeLOu+7YAj6APTX+CasR8
         nk5Oepzs35xQAv/4xypd6FwEwobQNmaoobb7jT92doNT28cKbKkxu2SdyJcD5T4U2oWl
         Va8IR153s2AsbseReLp59Y+f152aH/yzjjzlKqwnY4ZMtf2eWA/l9+1oMYtcjTsJk32r
         cu7fXFA7MebeMfTi7uY/MojFyAzrWYOjLZk498nK+8Q8LjXEoTSMFDd4XNzZM86kUgQ9
         FESQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=8bk9z1Ja4+T6AzhJsl417UlQDfrKqoRXML8B0kjTIwM=;
        b=HlFUaa0UwFZNodeyIgjdZnORgvg83OzC8BvlChdIUGwn7F70orlY1uoHdqVQGSWj/h
         lvvS2MZCR4pnmw8x8mADme6I9xYxcwAs9zr+sYW044WY+EfKcdk9VElO4C9V29l5RkrV
         ZJzCEkvPyRRDY9L49YvrhVevXN3pW7Y6iC2+sC5MbDECKMVqPlW2gJkgBGQ3g4yN4GeO
         7r7/EQ+fhNS+7uRtytLKyAJhuF8vbvNmtltG9CxgmFMZNr0ZiRhupA4yxhHtidZHhYCw
         5/ob2ouNfIviJsytI4OVlGk1mIB4ZJkZNYf3D3qlmDAsF9HPkeu/syAq27UiKuQiuNYv
         KiQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y41si24697056wrd.189.2019.04.10.04.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:05:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB2y-00053Y-7a; Wed, 10 Apr 2019 13:05:40 +0200
Message-Id: <20190410103644.574058244@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:05 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>
Subject: [RFC patch 11/41] mm/slub: Remove the ULONG_MAX stack trace hackery
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

While at it remove the pointless loop of clearing the stack array
completely. It's sufficient to clear the last entry as the consumers break
out on the first zeroed entry anyway.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -553,7 +553,6 @@ static void set_track(struct kmem_cache
 	if (addr) {
 #ifdef CONFIG_STACKTRACE
 		struct stack_trace trace;
-		int i;
 
 		trace.nr_entries = 0;
 		trace.max_entries = TRACK_ADDRS_COUNT;
@@ -563,20 +562,16 @@ static void set_track(struct kmem_cache
 		save_stack_trace(&trace);
 		metadata_access_disable();
 
-		/* See rant in lockdep.c */
-		if (trace.nr_entries != 0 &&
-		    trace.entries[trace.nr_entries - 1] == ULONG_MAX)
-			trace.nr_entries--;
-
-		for (i = trace.nr_entries; i < TRACK_ADDRS_COUNT; i++)
-			p->addrs[i] = 0;
+		if (trace.nr_entries < TRACK_ADDRS_COUNT)
+			p->addrs[trace.nr_entries] = 0;
 #endif
 		p->addr = addr;
 		p->cpu = smp_processor_id();
 		p->pid = current->pid;
 		p->when = jiffies;
-	} else
+	} else {
 		memset(p, 0, sizeof(struct track));
+	}
 }
 
 static void init_tracking(struct kmem_cache *s, void *object)


