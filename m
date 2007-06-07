Received: by ug-out-1314.google.com with SMTP id m2so612832uge
        for <linux-mm@kvack.org>; Wed, 06 Jun 2007 17:01:29 -0700 (PDT)
Message-ID: <29495f1d0706061701g449b0074ne329a7b7375efc56@mail.gmail.com>
Date: Wed, 6 Jun 2007 17:01:23 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <Pine.LNX.4.64.0706061646230.18160@schroedinger.engr.sgi.com>
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
	 <Pine.LNX.4.64.0706061349451.12665@schroedinger.engr.sgi.com>
	 <20070606161909.ea6a2556.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0706061646230.18160@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 6/6/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 6 Jun 2007, Andrew Morton wrote:
>
> > Did you try starting from the test.kernel.org config?
> > http://test.kernel.org/abat/93412/build/dotconfig
>
> Ok used that one but same result.
>
> There must be something trivial that I do not do right. The compile does
> not get that this is a 64 bit compile. Maybe I cannot do a 64 bit compile
> on a 32 bit system (this is i386)?
>
> clameter@schroedinger:~/software/slub$ cat /usr/local/bin/make_powerpc
> make ARCH=powerpc CROSS_COMPILE=powerpc-linux-gnu- $*

Hrm, what does V=1 say? Perhaps you need to somehow pass in -m64 or
something, if it's a biarch compiler (ppc32 and ppc64)?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
