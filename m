Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8D306B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:54:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so69940039lfd.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:54:48 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id j124si4021212wmg.99.2016.05.13.07.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:54:47 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e201so4215145wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:54:47 -0700 (PDT)
Date: Fri, 13 May 2016 16:54:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513145445.GT20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net>
 <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D77C.9090803@laposte.net>
 <50852f22-6030-7361-4273-91b5bea446ed@gmail.com>
 <5735E628.9080306@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735E628.9080306@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 16:35:20, Sebastian Frias wrote:
> Hi Austin,
> 
> On 05/13/2016 03:51 PM, Austin S. Hemmelgarn wrote:
> > On 2016-05-13 09:32, Sebastian Frias wrote:
> >> I didn't see that in Documentation/vm/overcommit-accounting or am I looking in the wrong place?
> > It's controlled by a sysctl value, so it's listed in Documentation/sysctl/vm.txt
> > The relevant sysctl is vm.oom_kill_allocating_task
> 
> Thanks, I just read that.
> Does not look like a replacement for overcommit=never though.

No this is just an OOM strategy. I wouldn't recommend it though because
the behavior might be really time dependant - unlike the regular OOM
killer strategy to select the largest memory consumer.

And again, overcommit=never doesn't imply no-OOM. It just makes it less
likely. The kernel can consume quite some unreclaimable memory as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
