Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA00324
	for <linux-mm@kvack.org>; Tue, 17 Sep 2002 14:06:49 -0700 (PDT)
Message-ID: <3D879968.B346D1C7@digeo.com>
Date: Tue, 17 Sep 2002 14:06:48 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [Lse-tech] Rollup patch of basic rmap against 2.5.26
References: <41260000.1032286918@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Scalability Effort List <lse-tech@lists.sourceforge.net>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> ...
>         daniel_rmap_speedup     Use hashed pte_chain locks

This one was shown to be a net loss on the NUMA-Q's.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
