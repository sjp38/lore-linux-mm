Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 719B160032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 08:29:23 -0400 (EDT)
Date: Thu, 20 May 2010 14:29:19 +0200
From: Heinz Diehl <htd@fancy-poultry.org>
Subject: Re: RFC: dirty_ratio back to 40%
Message-ID: <20100520122919.GA3420@fancy-poultry.org>
References: <4BF51B0A.1050901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BF51B0A.1050901@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 20.05.2010, Larry Woodman wrote: 

> Increasing the dirty_ratio to 40% will regain the performance loss seen
> in several benchmarks.  Whats everyone think about this???

These are tuneable via sysctl. What I have in my /etc/sysctl.conf is

 vm.dirty_ratio = 4
 vm.dirty_background_ratio = 2
 
This writes back the data more often and frequently, thus preventing the
system from long stalls. 

Works at least for me. AMD Quadcore, 8 GB RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
