Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA16429
	for <linux-mm@kvack.org>; Fri, 22 Nov 2002 11:52:18 -0800 (PST)
Message-ID: <3DDE8AF2.A5CD2FE3@digeo.com>
Date: Fri, 22 Nov 2002 11:52:18 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.5.48-mm1] Break COW page tables on mmap
References: <26960000.1037983225@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> I found a fairly large hole in my unsharing logic.  Pte page COW behavior
> breaks down when new objects are mapped.  This patch makes sure there
> aren't any COW pte pages in the range of a new mapping at mmap time.
> 
> This should fix the KDE problem.  It fixed it on the test machine I've been
> using.
> 

Fixed it for me too.  Congratulations.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
