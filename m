Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1C3056B004D
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 22:19:26 -0400 (EDT)
Date: Sun, 21 Jun 2009 19:20:01 -0700 (PDT)
Message-Id: <20090621.192001.46889618.davem@davemloft.net>
Subject: Re: handle_mm_fault() calling convention cleanup..
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: linux-arch@vger.kernel.org, hugh@veritas.com, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 21 Jun 2009 13:42:35 -0700 (PDT)

> I fixed up all architectures that I noticed (at least microblaze had been 
> added since the original patches in April), but arch maintainers should 
> double-check. Arch maintainers might also want to check whether the 
> mindless conversion of
> 
> 	'is_write' => 'is_write ? FAULT_FLAGS_WRITE : 0'
> 
> might perhaps be written in some more natural way (for example, maybe 
> you'd like to get rid of 'iswrite' as a variable entirely, and replace it 
> with a 'fault_flags' variable).
> 
> It's pushed out and tested on x86-64, but it really was such a mindless 
> conversion that I hope it works on all architectures. But I thought I'd 
> better give people a shout-out regardless.

Sparc looks good, and sparc64 seems to work fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
