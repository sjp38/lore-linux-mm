Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA21hC8m402158
	for <linux-mm@kvack.org>; Mon, 1 Nov 2004 20:43:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA21hCbN166588
	for <linux-mm@kvack.org>; Mon, 1 Nov 2004 18:43:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iA21hCkK001147
	for <linux-mm@kvack.org>; Mon, 1 Nov 2004 18:43:12 -0700
Message-ID: <4186E62E.9000609@us.ibm.com>
Date: Mon, 01 Nov 2004 17:43:10 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
References: <Pine.SGI.4.58.0411011901540.77038@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0411011901540.77038@kzerza.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Brent Casavant wrote:
> This patch causes memory allocation for tmpfs files to be distributed
> evenly across NUMA machines.  In most circumstances today, tmpfs files
> will be allocated on the same node as the task writing to the file.
> In many cases, particularly when large files are created, or a large
> number of files are created by a single task, this leads to a severe
> imbalance in free memory amongst nodes.  This patch corrects that
> situation.

Why don't you just use the NUMA API in your application for this?  Won't 
this hurt any application that uses tmpfs and never leaves a node in its 
lifetime, like a short gcc run?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
