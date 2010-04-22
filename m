Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6A80C6B01F6
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 11:28:54 -0400 (EDT)
Message-ID: <4BD06B31.9050306@redhat.com>
Date: Thu, 22 Apr 2010 18:28:49 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
In-Reply-To: <20100422134249.GA2963@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/22/2010 04:42 PM, Dan Magenheimer wrote:
> Frontswap is so named because it can be thought of as the opposite of
> a "backing" store for a swap device.  The storage is assumed to be
> a synchronous concurrency-safe page-oriented pseudo-RAM device (such as
> Xen's Transcendent Memory, aka "tmem", or in-kernel compressed memory,
> aka "zmem", or other RAM-like devices) which is not directly accessible
> or addressable by the kernel and is of unknown and possibly time-varying
> size.  This pseudo-RAM device links itself to frontswap by setting the
> frontswap_ops pointer appropriately and the functions it provides must
> conform to certain policies as follows:
>    

How baked in is the synchronous requirement?  Memory, for example, can 
be asynchronous if it is copied by a dma engine, and since there are 
hardware encryption engines, there may be hardware compression engines 
in the future.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
