Date: Mon, 31 Jan 2005 16:44:22 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20050131184422.GD15694@logos.cnet>
References: <20041123121447.GE4524@logos.cnet> <20041124.192156.73388074.taka@valinux.co.jp> <20041201202101.GB5459@dmt.cyclades> <20041208.222307.64517559.taka@valinux.co.jp> <20050117095955.GC18785@logos.cnet> <41FE79EF.8040204@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41FE79EF.8040204@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2005 at 12:33:19PM -0600, Ray Bryant wrote:
> Marcello and Hirokazu,
> 
> I've finally gotten around to working on my user controlled page migration 
> project.  (What I'm trying to implement is a way for a suitably authorized
> user program to request that some or all of the pages or a particular 
> address
> space be migrated from one NUMA node to another.)
> 
> The first such thing to try to migrate is anonymous, private pages so that
> is what I am working on.  To keep things simple, the user program is trying
> to migrate part of its own address space.
> 
> What I have found out is that this works correctly with the page-migration
> patch (extracted from the memory hotplug patch, e. g.:
> 
> http://sr71.net/patches/2.6.10/2.6.10-mm1-mhp-test7/page_migration/
> 
> ) but when I apply the migration cache patch on top what happens is that
> the migration appears to occur, but then as soon as I return from the
> system call, I get:
> 
> VM: killing process test
> Killed
> 
> (This message comes from ia64_do_page_fault() and appears to because
> handle_mm_fault() returned FAULT_OOM....)
> 
> I haven't looked into this further, but was wondering if perhaps one of
> you would understand why the migrate cache patch would fail in this way?

I can't think of anything right now - probably do_wp_page() is returning FAULT_OOM,
can you confirm that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
