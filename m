Received: by rv-out-0910.google.com with SMTP id f1so1400145rvb.26
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 19:18:51 -0700 (PDT)
Message-ID: <86802c440803241918y4e1589e5h6319806238ecd00b@mail.gmail.com>
Date: Mon, 24 Mar 2008 19:18:50 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 1/8] x86_64: Change GET_APIC_ID() from an inline function to an out-of-line function
In-Reply-To: <20080325013759.GA16549@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182107.GA27979@sgi.com>
	 <86802c440803241534p5c28193brf769280fe05d286d@mail.gmail.com>
	 <20080325013759.GA16549@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 6:37 PM, Jack Steiner <steiner@sgi.com> wrote:
> > >  Index: linux/include/asm-x86/apicdef.h
>  > >  ===================================================================
>  > >  --- linux.orig/include/asm-x86/apicdef.h        2008-03-18 14:54:19.000000000 -0500
>  > >  +++ linux/include/asm-x86/apicdef.h     2008-03-21 09:07:23.000000000 -0500
>  > >  @@ -14,7 +14,6 @@
>  > >
>  > >   #ifdef CONFIG_X86_64
>  > >   # define       APIC_ID_MASK            (0xFFu<<24)
>  > >  -# define       GET_APIC_ID(x)          (((x)>>24)&0xFFu)
>  > >   # define       SET_APIC_ID(x)          (((x)<<24))
>  > >   #endif
>  >
>  > it this patch after smpboot.c integration?
>  >
>  > that patchsets have GET_APIC_ID in mach_apicdef.h instead of apicdef.h
>  >
>
>  Sorry - I meant to add to the patches that they are based on linux-2.6.25-rc5-mm1.
>  Was the change to smpboot.c made in -rc6??

x86.git#latest

http://people.redhat.com/mingo/x86.git/README

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
