Received: from fmsmsxvs041.fm.intel.com (fmsmsxvs041.fm.intel.com [132.233.42.126])
	by mail2.hd.intel.com (8.11.6/8.11.6/d: solo.mc,v 1.43 2002/08/30 20:06:11 dmccart Exp $) with SMTP id g8BHdqI19987
	for <linux-mm@kvack.org>; Wed, 11 Sep 2002 17:39:52 GMT
Message-ID: <25282B06EFB8D31198BF00508B66D4FA03EA5806@fmsmsx114.fm.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: RE: [PATCH] Config.help entry for CONFIG_HUGETLB_PAGE
Date: Wed, 11 Sep 2002 10:39:47 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Steven Cole' <elenstev@mesatop.com>, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Seth, Rohit" <rohit.seth@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Steve.  Your description in config.help file looks good.


> -----Original Message-----
> From: Steven Cole [mailto:elenstev@mesatop.com]
> Sent: Wednesday, September 11, 2002 8:18 AM
> To: Martin J. Bligh
> Cc: Andrew Morton; Seth, Rohit; linux-mm@kvack.org
> Subject: Re: [PATCH] Config.help entry for CONFIG_HUGETLB_PAGE
> 
> 
> On Wed, 2002-09-11 at 09:05, Martin J. Bligh wrote:
> >  
> > > +CONFIG_HUGETLB_PAGE
> > > +  This enables support for huge pages (4MB for x86).  User space
> > > +  applications can make use of this support with the 
> sys_alloc_hugepages
> > > +  and sys_free_hugepages system calls.  If your applications are
> > > +  huge page aware and your processor (Pentium or later 
> for x86) supports
> > > +  this, then say Y here.
> > > +
> > > +  Otherwise, say N.
> > 
> > They're not always 4Mb on x86 ... they're 2Mb if you have PAE 
> > turned on ... maybe just leave out the "(4MB for x86)" comment?
> > 
> > M.
> 
> Better?
> 
> --- linux-2.5.34-mm1/arch/i386/Config.help.orig	Wed Sep 
> 11 07:54:49 2002
> +++ linux-2.5.34-mm1/arch/i386/Config.help	Wed Sep 11 09:14:52 2002
> @@ -25,6 +25,15 @@
>  
>    If you don't know what to do here, say N.
>  
> +CONFIG_HUGETLB_PAGE
> +  This enables support for huge pages.  User space applications
> +  can make use of this support with the sys_alloc_hugepages and
> +  sys_free_hugepages system calls.  If your applications are
> +  huge page aware and your processor (Pentium or later for x86)
> +  supports this, then say Y here.
> +
> +  Otherwise, say N.
> +
>  CONFIG_PREEMPT
>    This option reduces the latency of the kernel when reacting to
>    real-time or interactive events by allowing a low priority 
> process to
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
