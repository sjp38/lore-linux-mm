Date: Mon, 2 Apr 2001 20:17:50 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: [PATCH] Reclaim orphaned swap pages 
Message-ID: <Pine.LNX.4.30.0104021952000.406-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Jerrell <jerrell@missioncriticallinux.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> From what I can see of the patch vm_enough_memory will still fail
> causing premature oom

Actually if vm_enough_memory fails that prevents oom, apps get ENOMEM
instead of killed by oom_kill later. Moreover vm_enough_memory is long
different and apparently it's just overestimating free pages that makes
people unhappy with the resulted higher oom_kill/ENOMEM rate. If you
want to prevent premature oom you should patch out_of_memory but be
careful if you overestimate you can/will lockup. Anyway I think the
right place for oom_kill would be in the page fault handler [just as for
early kernels] but this needs a small change in __alloc_pages otherwise
processes get stuck there [see goto try_again] when system is low on
memory.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
