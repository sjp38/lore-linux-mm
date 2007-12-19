Message-ID: <476924E0.8010304@de.ibm.com>
Date: Wed, 19 Dec 2007 15:04:16 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de>
In-Reply-To: <20071214134106.GC28555@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> This is just a prototype for one possible way of supporting this. I may
> be missing some important detail or eg. have missed some requirement of the
> s390 XIP block device that makes the idea infeasible... comments?
I've tested your patch series on s390 with dcssblk block device and 
ext2 file system with -o xip. Everything seems to work fine. I will 
now patch my kernel not to build struct page for the shared segment 
and see if that works too.

so long,
Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
