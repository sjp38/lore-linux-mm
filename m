Date: Mon, 28 Feb 2005 16:42:34 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/5] prepare x86/ppc64 DISCONTIG code for hotplug
Message-Id: <20050228164234.38cb774c.akpm@osdl.org>
In-Reply-To: <1109616858.6921.39.camel@localhost>
References: <1109616858.6921.39.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: kmannth@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
> Subject pretty much says it all.  Descriptions are in the individual
> patches.  These patches replace the
> "allow-hot-add-enabled-i386-numa-box-to-boot.patch" which is currently
> in -mm.  Please drop it.  
> 
> They apply to 2.6.11-rc5 after a few patches from -mm which conflicted:
> 
> 	stop-using-base-argument-in-__free_pages_bulk.patch
> 	consolidate-set_max_mapnr_init-implementations.patch
> 	refactor-i386-memory-setup.patch
> 	remove-free_all_bootmem-define.patch
> 	mostly-i386-mm-cleanup.patch
> 
> Boot-tested on plain x86 laptop, NUMAQ, and Summit.  These probably
> deserve to stay in -mm for a release or two.
> 

Most of these patches needed little fixups due to other patches which you
folks have already sent me:

	allow-hot-add-enabled-i386-numa-box-to-boot
	refactor-i386-memory-setup
	consolidate-set_max_mapnr_init-implementations

I'll try to get a -mm out this evening - please retest this stuff.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
