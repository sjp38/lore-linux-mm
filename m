Date: Wed, 13 Sep 2006 10:32:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: why inode creation with GFP_HIGHUSER?
In-Reply-To: <34a75100609130754t24b8bde6xcebda4f0684c51cb@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0609131030580.17927@schroedinger.engr.sgi.com>
References: <34a75100609130734m68729bdaj30258c10edfa7947@mail.gmail.com>
 <34a75100609130754t24b8bde6xcebda4f0684c51cb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: girish <girishvg@gmail.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, girish wrote:

> i'd like to know why page(s) for inodes are allocated with
> GFP_HIGHUSER & not with GFP_USER mask? is there any particular need
> that the address_space be set with GFP_HIGHUSER flag?

GFP_HIGHUSER allows the use of HIGH memory but it does not require it. If 
the system has no HIGHMEM then we will just use regular memory.

> i intend to allocate highmem pages strictly to user processes. my idea
> is to completely avoid kernel mapping for these pages. so, as a dirty
> hack - i changed mapping_set_gfp_mask function not to honor
> __GFP_HIGHMEM zone selector if __GFP_IO | __GFP_FS are set. in short i
> replace  GFP_HIGHUSER with GFP_USER mask. with this change the kernel
> comes to life. but i am still confused about the effect of this change
> on system, that i am yet to see?

I am not sure what you intend to do. The kernel already avoids mapping 
highmem pages into the kernel as much as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
