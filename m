Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2332A6B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 07:27:58 -0400 (EDT)
Date: Wed, 24 Jun 2009 17:04:21 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] transcendent memory for Linux
Message-ID: <20090624150420.GH1784@ucw.cz>
References: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

Hi!

This description (whole mail) needs to go into Documentation/, somewhere. 

> Normal memory is directly addressable by the kernel,
> of a known normally-fixed size, synchronously accessible,
> and persistent (though not across a reboot).
...
> Transcendent memory, or "tmem" for short, provides a
> well-defined API to access this unusual class of memory.
> The basic operations are page-copy-based and use a flexible
> object-oriented addressing mechanism.  Tmem assumes

Should this API be documented, somewhere? Is it in-kernel API or does
userland see it?

> "Preswap" IS persistent, but for various reasons may not always
> be available for use, again due to factors that may not be
> visible to the kernel (but, briefly, if the kernel is being
> "good" and has shared its resources nicely, then it will be
> able to use preswap, else it will not).  Once a page is put,
> a get on the page will always succeed.  So when the kernel
> finds itself in a situation where it needs to swap out a page,
> it first attempts to use preswap.  If the put works, a disk
> write and (usually) a disk read are avoided.  If it doesn't,
> the page is written to swap as usual.  Unlike precache, whether

Ok, how much slower this gets in the worst case? Single hypercall to
find out that preswap is unavailable? I guess that compared to disk
access that's lost in the noise?
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
