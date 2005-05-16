Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4GHUgT9510658
	for <linux-mm@kvack.org>; Mon, 16 May 2005 13:30:42 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GHUgGc179512
	for <linux-mm@kvack.org>; Mon, 16 May 2005 11:30:42 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4GHUgYp018849
	for <linux-mm@kvack.org>; Mon, 16 May 2005 11:30:42 -0600
Subject: Re: /proc/meminfo
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <6934efce05051610252b84713f@mail.gmail.com>
References: <6934efce05051610252b84713f@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 16 May 2005 10:30:29 -0700
Message-Id: <1116264629.1005.75.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 10:25 -0700, Jared Hulbert wrote:
> Please have mercy on a linux-mm newbie.  I'd like to understand the
> output of /proc/meminfo and /proc/<[0-9]+>/maps.  I want to measure 2
> things: First, how much memory in a system is used for code or other
> readonly file mmaps or what RAM can be saved by using XIP flash.
> Second, at the time a system snapshot is taken how much RAM is
> absolutely needed (for example, I assume we could dump caches, flush
> buffers, and clean up unused memory.)
> 
> Where can I find a good reference to what this all output means?  Are
> there other sources of information available?

Documentation/filesystems/proc.txt

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
