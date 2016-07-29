Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 888AC6B0260
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:19:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so41651214wmz.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:19:12 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id hn8si19354158wjc.252.2016.07.29.08.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 08:19:10 -0700 (PDT)
Date: Fri, 29 Jul 2016 11:19:07 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.7+] various memory corruption reports.
Message-ID: <20160729151907.GC29545@codemonkey.org.uk>
References: <20160729150513.GB29545@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729150513.GB29545@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, Jul 29, 2016 at 11:05:14AM -0400, Dave Jones wrote:
 > I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
 > right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.
 > 
 > ,,,
 >
 > I'll work on narrowing down the exact syscalls needed to trigger this.

Even limiting it to do just a simple syscall like execve (which fails most the time in trinity)
triggers it, suggesting it's not syscall related, but the fact that trinity is forking/killing
tons of processes at high rate is stressing something more fundamental.

Given how easy this reproduces, I'll see if bisecting gives up something useful.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
