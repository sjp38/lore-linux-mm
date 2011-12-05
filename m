Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id ECE266B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 13:15:52 -0500 (EST)
Date: Mon, 5 Dec 2011 19:15:49 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111205181549.GA1612@x4.trippels.de>
References: <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
 <20111202230412.GB12057@homer.localdomain>
 <20111203092845.GA1520@x4.trippels.de>
 <CAPM=9tyjZc9waC_ZBygW9zh+Zq-Wb1X5Y6yfsCCMPYwpFVWOOg@mail.gmail.com>
 <20111203122900.GA1617@x4.trippels.de>
 <CAH3drwZDOpPuQ_G=LwTiNsR5BNyJTNr+VJU74E6nS5AbKyQH0A@mail.gmail.com>
 <20111204010200.GA1530@x4.trippels.de>
 <20111205171046.GA4342@homer.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111205171046.GA4342@homer.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Dave Airlie <airlied@gmail.com>, Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>

On 2011.12.05 at 12:10 -0500, Jerome Glisse wrote:
> On Sun, Dec 04, 2011 at 02:02:00AM +0100, Markus Trippelsdorf wrote:
> > On 2011.12.03 at 14:31 -0500, Jerome Glisse wrote:
> > > On Sat, Dec 3, 2011 at 7:29 AM, Markus Trippelsdorf
> > > <markus@trippelsdorf.de> wrote:
> > > > On 2011.12.03 at 12:20 +0000, Dave Airlie wrote:
> > > >> >> > > > > FIX idr_layer_cache: Marking all objects used
> > > >> >> > > >
> > > >> >> > > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > > >> >> > > > exactly the same spot again. (CCing the drm list)
> > > >>
> > > >> If I had to guess it looks like 0 is getting written back to some
> > > >> random page by the GPU maybe, it could be that the GPU is in some half
> > > >> setup state at boot or on a reboot does it happen from a cold boot or
> > > >> just warm boot or kexec?
> > > >
> > > > Only happened with kexec thus far. Cold boot seems to be fine.
> > > >
> > > 
> > > Can you add radeon.no_wb=1 to your kexec kernel paramater an see if
> > > you can reproduce.
> > 
> > No, I cannot reproduce the issue with radeon.no_wb=1. (I write this
> > after 700 successful kexec iterations...)
> > 
> 
> Can you try if attached patch fix the issue when you don't pass the
> radeon.no_wb=1 option ?

Yes the patch finally fixes the issue for me (tested with 120 kexec
iterations).
Thanks Jerome!

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
