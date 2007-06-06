Received: by ug-out-1314.google.com with SMTP id m2so608551uge
        for <linux-mm@kvack.org>; Wed, 06 Jun 2007 16:31:18 -0700 (PDT)
Message-ID: <29495f1d0706061631p63e3fe3dta9de26e79474bc9f@mail.gmail.com>
Date: Wed, 6 Jun 2007 16:31:18 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <46671C16.9080409@mbligh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
	 <20070606100817.7af24b74.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
	 <20070606131121.a8f7be78.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
	 <20070606133432.2f3cb26a.akpm@linux-foundation.org>
	 <46671C16.9080409@mbligh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 6/6/07, Martin Bligh <mbligh@mbligh.org> wrote:
> Andrew Morton wrote:
> > On Wed, 6 Jun 2007 13:28:40 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> >
> >> On Wed, 6 Jun 2007, Andrew Morton wrote:
> >>
> >>>> There is also nothing special in CalcNTLMv2_partial_mac_key(). Two
> >>>> kmallocs of 33 bytes and 132 bytes each.
> >>> Yes, the code all looks OK.  I suspect this is another case of the compiler
> >>> failing to remove unreachable stuff.
> >> Sigh.
> >>
> >> The patch was already in 2.6.22-rc3-mm1. Why did the patch pass the
> >> testing during that release cycle?
> >
> > Good question - don't know, sorry.
> >
> > I tried to build gcc-3.3.3 the other day.  Would you believe that gcc-4.1.0
> > fails to compile gcc-3.3.3?
>
> IIRC, the SUSE ones were customized anyway, so not sure that'd help you.
> Might do though.
>
> There should be a sysinfo directory that lists stuff like gcc version,
> maybe it's not getting replicated to TKO though ... Nish or Andy,
> any chance you can take a look at the original copy of one of those
> jobs on the ABAT server?

Looked at this one --  I could have sworn there was a sysinfo
directory at some point too. But I don't see it on the ABAT job. There
is a compiler.ver, and it contains what I pasted before essentially:

Reading specs from /usr/lib/gcc-lib/powerpc-suse-linux/3.3.3/specs
Configured with: ../configure --enable-threads=posix --prefix=/usr
--with-local-prefix=/usr/local --infodir=/usr/share/info
--mandir=/usr/share/man --enable-languages=c,c++,f77,objc,java,ada
--disable-checking --libdir=/usr/lib --enable-libgcj
--with-gxx-include-dir=/usr/include/g++ --with-slibdir=/lib
--with-system-zlib --enable-shared --enable-__cxa_atexit
--host=powerpc-suse-linux --build=powerpc-suse-linux
--target=powerpc-suse-linux --enable-targets=powerpc64-suse-linux
--enable-biarch
Thread model: posix
gcc version 3.3.3 (SuSE Linux)

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
