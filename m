Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 451DB6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 08:57:53 -0500 (EST)
Message-ID: <4F1D675D.5070800@redhat.com>
Date: Mon, 23 Jan 2012 08:57:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] [ATTEND] memory compaction & ballooning
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>

KVM guests benefit a lot from being able to use transparent
hugepages in both the host and the guest, cutting the number
of memory accesses to fill a TLB entry almost in half when
using EPT/NPT.

However, currently memory is ballooned in 4kB units, leading
to fragmentation of guest memory and an inability to use 2MB
pages.  One obvious fix is to do memory ballooning in 2MB
increments, however there appear to be several obstacles in
the way of compaction actually creating contiguous 2MB areas
of free memory.

I would like to discuss / brainstorm improvements to
compaction and ways to keep memory allocations better
separated, to be better able to come up with contiguous
2MB areas.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
