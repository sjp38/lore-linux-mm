From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17026.45684.442592.17147@gargle.gargle.HOWL>
Date: Wed, 11 May 2005 21:33:40 -0400
Subject: Re: [PATCH] Avoiding mmap fragmentation  (against 2.6.12-rc4) to
In-Reply-To: <20050511175901.15fa7b95.akpm@osdl.org>
References: <20050510115818.0828f5d1.akpm@osdl.org>
	<200505101934.j4AJYfg26483@unix-os.sc.intel.com>
	<20050510124357.2a7d2f9b.akpm@osdl.org>
	<17025.4213.255704.748374@gargle.gargle.HOWL>
	<20050510125747.65b83b4c.akpm@osdl.org>
	<17026.6227.225173.588629@gargle.gargle.HOWL>
	<20050511175901.15fa7b95.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, kenneth.w.chen@intel.com, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Wolfgang Wander <wwc@rentec.com> wrote:
 > >
 > > diff -rpu linux-2.6.12-rc4-vanilla/fs/binfmt_elf.c linux-2.6.12-rc4-wwc/fs/binfmt_elf.c
 > >  --- linux-2.6.12-rc4-vanilla/fs/binfmt_elf.c	2005-05-10 18:28:59.958415676 -0400
 > >  +++ linux-2.6.12-rc4-wwc/fs/binfmt_elf.c	2005-05-10 16:34:23.696894470 -0400
 > >  @@ -775,6 +775,7 @@ static int load_elf_binary(struct linux_
 > >   	   change some of these later */
 > >   	set_mm_counter(current->mm, rss, 0);
 > >   	current->mm->free_area_cache = current->mm->mmap_base;
 > >  +	current->mm->cached_hole_size = current->mm->cached_hole_size;
 > 
 > eh?

Outch!  Good catch. Thanks Andrew!

Ken, when you post your revised version can you replace this line
with 

+ current->mm->cached_hole_size = ~0UL;

Same problem in binfmt_aout.c!

Since we set free_area_cache to mmap_base the bug is hardly able to
cause any real harm but it looks more than silly.

    Wolfgang
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
