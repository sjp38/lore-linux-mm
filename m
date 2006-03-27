Date: Sun, 26 Mar 2006 23:29:46 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: Add gfp flag __GFP_POLICY to control policies and cpusets
 redirection of allocations
Message-Id: <20060326232946.620f9f60.pj@sgi.com>
In-Reply-To: <20060324174448.0ac4a520.pj@sgi.com>
References: <Pine.LNX.4.64.0603221342170.24959@schroedinger.engr.sgi.com>
	<20060324174448.0ac4a520.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, clameter@sgi.com, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  (Executive, aka Andrew, summary: no action items here yet ...)

Christoph sent me some corrections offline to my previous post.

I (pj) had written:
> This patch does not always fix the problem that first motivated it of
> failed memory migrations,

I had misunderstood Christoph's patch.  He never intended to fix the
cpuset induced failure of memory migration.  He intended to restore 
proper behavior of the slab allocator and other kernel subsystems.

Part of my confusion arose from the fact that he took the occassion of
his patch to ask Andrew to drop an earlier patch of ours that -had-
intended, in part, to fix this cpuset-migration interaction.

And part of my confusion was just plain old confusion on my part.


>      If I get the chance this weekend, I will at least try to
>      write up an lkml post describing some of the '(mis)features' we
>      observed during our analysis of this area, under some such Subject
>      as "Misfeatures of the kernel allocators and memory policy."

I won't get that far.  I'm still working with Christoph offline to make
sense of this.  Hopefully I won't drive him to drink first ;-).

I still hope to have a much improved, agreed to by Christoph, patch to
fix the cpuset-migration interaction, posted to lkml in a day or two.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
