Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 77AEC6B002F
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 04:07:09 -0400 (EDT)
From: Pawel Sikora <pluto@agmk.net>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Date: Fri, 21 Oct 2011 10:07:05 +0200
Message-ID: <2109011.boM0eZ0ZTE@pawels>
In-Reply-To: <CAPQyPG6d3Sv26SiR6Xj4S5xOOy2DmrwQYO2wAwzrcg=2A0EcMQ@mail.gmail.com>
References: <201110122012.33767.pluto@agmk.net> <CANsGZ6a6_q8+88FRV2froBsVEq7GhtKd9fRnB-0M2MD3a7tnSw@mail.gmail.com> <CAPQyPG6d3Sv26SiR6Xj4S5xOOy2DmrwQYO2wAwzrcg=2A0EcMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Friday 21 of October 2011 14:22:37 Nai Xia wrote:

> And as a side note. Since I notice that Pawel's workload may include OOM,

my last tests on patched (3.0.4 + migrate.c fix + vserver) kernel produce full cpu load
on dual 8-cores opterons like on this htop screenshot -> http://pluto.agmk.net/kernel/screen1.png
afaics all userspace applications usualy don't use more than half of physical memory
and so called "cache" on htop bar doesn't reach the 100%.

the patched kernel with disabled CONFIG_TRANSPARENT_HUGEPAGE (new thing in 2.6.38)
died at night, so now i'm going to disable also CONFIG_COMPACTION/MIGRATION in next
steps and stress this machine again...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
