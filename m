Received: by zproxy.gmail.com with SMTP id k1so351884nzf
        for <linux-mm@kvack.org>; Mon, 03 Oct 2005 22:06:55 -0700 (PDT)
Message-ID: <aec7e5c30510032206l12f666a0lef42ba7919d860fe@mail.gmail.com>
Date: Tue, 4 Oct 2005 14:06:55 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 07/07] i386: numa emulation on pc
In-Reply-To: <1128356192.10290.10.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <20050930073308.10631.24247.sendpatchset@cherry.local>
	 <1128106512.8123.26.camel@localhost>
	 <aec7e5c30510030259j2698f982ue7169768730f3d53@mail.gmail.com>
	 <1128356192.10290.10.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Isaku Yamahata <yamahata@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/4/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Mon, 2005-10-03 at 18:59 +0900, Magnus Damm wrote:
> > > > +#ifdef CONFIG_NUMA_EMU
> > > ...
> > > > +#endif
> > >
> > > Ewwwwww :)  No real need to put new function in a big #ifdef like that.
> > > Can you just create a new file for NUMA emulation?
> >
> > Hehe, what is this, a beauty contest? =) I agree, but I guess the
> > reason for this code to be here is that a similar arrangement is done
> > by x86_64...
>
> If that's really the case, can they _actually_ share code?  Maybe we can
> do this NUMA emulation thing in non-arch code.  Just guessing...

I'd like to avoid duplication as much as you, but at a quick glance
the x86_64 and i386 architecture looked pretty different. But I will
see what I can do.

> > I will create a new file. Is arch/i386/mm/numa_emu.c good?
>
> > But first, you have written lots and lots of patches, and I am
> > confused. Could you please tell me on which patches I should base my
> > code to make things as easy as possible?
>
> This is the staging ground for my memory hotplug work.  But, it contains
> all of my work on other stuff, too.  If you build on top of this, it
> would be great:
>
> http://sr71.net/patches/2.6.14/2.6.14-rc2-git8-mhp1/

I will build on top of that then.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
