Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF1326001DA
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 03:26:48 -0500 (EST)
Date: Tue, 19 Jan 2010 10:26:38 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119082638.GK14345@redhat.com>
References: <20100118141938.GI30698@redhat.com>
 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
 <20100118170816.GA22111@redhat.com>
 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
 <20100118181942.GD22111@redhat.com>
 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
 <20100119071734.GG14345@redhat.com>
 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
 <20100119075205.GI14345@redhat.com>
 <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 10:07:07AM +0200, Pekka Enberg wrote:
> Hi Gleb,
> 
> On Tue, Jan 19, 2010 at 9:52 AM, Gleb Natapov <gleb@redhat.com> wrote:
> >> It would be probably useful if you could point us to the application
> >> source code that actually wants this feature.
> >>
> > This is two line patch to qemu that calls mlockall(MCL_CURRENT|MCL_FUTURE)
> > at the beginning of the main() and changes guest memory allocation to
> > use MAP_UNLOCKED flag. All alternative solutions in this thread suggest
> > that I should rewrite qemu + all library it uses. You see why I can't
> > take them seriously?
> 
> Well, that's not going to be portable, is it, so the application
KVM is not portable ;) and that is what my main interest is.

> design would still be broken, no? Did you try using (or extending)
> posix_madvise(MADV_DONTNEED) for the guest address space? It seems to
After mlockall() I can't even allocate guest address space. Or do you mean
instead of mlockall()? Then how MADV_DONTNEED will help? It just drops
page table for the address range (which is not what I need) and does not
have any long time effect.

> me that you're trying to use a big hammer (mlock) when a polite hint
> for the VM would probably be sufficient for it do its job.
> 
I what to tell to VM "swap this, don't swap that" and as far as I see
there is no other way to do it currently.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
