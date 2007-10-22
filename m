Received: by nz-out-0506.google.com with SMTP id s1so544076nze
        for <linux-mm@kvack.org>; Mon, 22 Oct 2007 10:03:20 -0700 (PDT)
Message-ID: <45a44e480710221003u4b6d9e84n98599c97b9dab95@mail.gmail.com>
Date: Mon, 22 Oct 2007 13:03:20 -0400
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <Pine.LNX.4.64.0710221719420.13779@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1193064305.16541.3.camel@matrix>
	 <Pine.LNX.4.64.0710221719420.13779@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Stefani Seibold <stefani@seibold.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
>
> Interesting.  You need to ask Jaya (CC'ed) since he's the one
> who put that code into fb_defio.c, exported page_mkclean, and
> should have tested it.

Thanks Hugh.

Yes, hecubafb uses fb_defio (which is infrastructure code) which uses
mkwrite/mkclean. This was tested and it worked great on x86 with
2.6.21 when I posted the patches.

I will be trying in the next few weeks to finish up a driver for the
current E-Ink Vizplex+controller working on arm with 2.6.22. So since
page_mkclean has changed, I will try to work on a update for fb_defio
at that time.

>
> >
> > I am not sure if the is a feature of the new rmap code or a bug.
>
> page_mkclean was written in the belief that it was being used on
> pagecache pages.  I'm not sure how deeply engrained that belief is.
>
> If it can easily and safely be used on something else, that may be
> nice: though there's a danger we'll keep breaking and re-breaking
> it if there's only one driver using it in an unusual way.  CC'ed
> Peter since he's the one who most needs to be aware of this.

Yes, right now, only hecubafb uses deferred IO and thus page_mkclean.
But I believe that usage will increase. I hope together we can get it
fixed up and keep it working long term. I think deferred IO gives
linux a nice advantage when interfacing with high latency displays (of
which one will increasingly see more of).

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
