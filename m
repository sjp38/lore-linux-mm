Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 2C1A66B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 15:16:55 -0500 (EST)
Received: by qcsd17 with SMTP id d17so2126347qcs.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 12:16:54 -0800 (PST)
Date: Mon, 5 Dec 2011 15:20:57 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111205202057.GD4342@homer.localdomain>
References: <20111203092845.GA1520@x4.trippels.de>
 <CAPM=9tyjZc9waC_ZBygW9zh+Zq-Wb1X5Y6yfsCCMPYwpFVWOOg@mail.gmail.com>
 <20111203122900.GA1617@x4.trippels.de>
 <CAH3drwZDOpPuQ_G=LwTiNsR5BNyJTNr+VJU74E6nS5AbKyQH0A@mail.gmail.com>
 <20111204010200.GA1530@x4.trippels.de>
 <20111205171046.GA4342@homer.localdomain>
 <20111205181549.GA1612@x4.trippels.de>
 <20111205191116.GB4342@homer.localdomain>
 <20111205192701.GA1531@x4.trippels.de>
 <CAOJsxLGCrNZnxZ70vpRGZ35GMK4MPDc4r6S=KTngQuL0eED94w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="TYecfFk8j8mZq+dy"
Content-Disposition: inline
In-Reply-To: <CAOJsxLGCrNZnxZ70vpRGZ35GMK4MPDc4r6S=KTngQuL0eED94w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Dave Airlie <airlied@gmail.com>, Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>


--TYecfFk8j8mZq+dy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 05, 2011 at 10:10:34PM +0200, Pekka Enberg wrote:
> On Mon, Dec 5, 2011 at 9:27 PM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> >> > Yes the patch finally fixes the issue for me (tested with 120 kexec
> >> > iterations).
> >> > Thanks Jerome!
> >>
> >> Can you do a kick run on the modified patch ?
> >
> > This one is also OK after ~60 iterations.
> 
> Jerome, could you please include a reference to this LKML thread for
> context and attribution for Markus for reporting and following up to
> get the issue fixed in the changelog?
> 
>                               Pekka

Attached updated patch, only changelog is different. Thanks Markus for
testing this.

Cheers,
Jerome

--TYecfFk8j8mZq+dy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-drm-radeon-disable-possible-GPU-writeback-early-v3.patch"


--TYecfFk8j8mZq+dy--
