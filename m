Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BAE666B00AC
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:12:50 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id k29so2827223rvb.26
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 06:12:49 -0800 (PST)
Date: Wed, 4 Mar 2009 23:12:40 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] generic debug pagealloc
Message-ID: <20090304141238.GA7168@localhost.localdomain>
References: <20090303160103.GB5812@localhost.localdomain> <20090303160503.GA6538@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20090303160503.GA6538@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 05:05:03PM +0100, Ingo Molnar wrote:
> if every architecture supports it now then i guess this config 
> switch can go away:
> 
> > +config ARCH_SUPPORTS_DEBUG_PAGEALLOC
> > +	def_bool y

The generic debug pagealloc needs the poison flag for each struct page.

So I introduced CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC for x86, powerpc,
sparc (64bit), and s390. If there is no CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC,
make config prompts the generic debug pagealloc in mm/Kconfig.debug for the
other architectures.

I was trying to add cleaner config dependency but
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC is my solution for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
