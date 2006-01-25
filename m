Received: by uproxy.gmail.com with SMTP id k40so127492ugc
        for <linux-mm@kvack.org>; Wed, 25 Jan 2006 03:19:36 -0800 (PST)
Message-ID: <84144f020601250319o71e34376hcd7a964f2eb21961@mail.gmail.com>
Date: Wed, 25 Jan 2006 13:19:36 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC] non-refcounted pages, application to slab?
In-Reply-To: <20060125110031.GC30421@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060125093909.GE32653@wotan.suse.de>
	 <84144f020601250230s2d5da5d9jf11f754f184d495b@mail.gmail.com>
	 <20060125110031.GC30421@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 12:30:03PM +0200, Pekka Enberg wrote:
> > we want to keep the reference counting for slab pages so that we can
> > use kmalloc'd memory in the block layer.

On 1/25/06, Nick Piggin <npiggin@suse.de> wrote:
> Does that happen now? Where is it needed (nbd or something I guess?)

See the following thread:
http://thread.gmane.org/gmane.comp.file-systems.ext2.devel/2981. I
think we're using them in quite a few places.

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
