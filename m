Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD1E96B0283
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 03:15:41 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id i6so6559946wre.6
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 00:15:41 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id l127si7511080wmb.121.2018.01.08.00.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 00:15:40 -0800 (PST)
Message-ID: <1515399333.20268.23.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 08 Jan 2018 09:15:33 +0100
In-Reply-To: <20180108075308.GC24062@kroah.com>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de> <20180107091115.GB29329@kroah.com>
	 <20180107101847.GC24862@dhcp22.suse.cz> <1515329042.13953.14.camel@gmx.de>
	 <20180107132309.GD24862@dhcp22.suse.cz> <20180108075308.GC24062@kroah.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Mon, 2018-01-08 at 08:53 +0100, Greg Kroah-Hartman wrote:
> On Sun, Jan 07, 2018 at 02:23:09PM +0100, Michal Hocko wrote:
> > On Sun 07-01-18 13:44:02, Mike Galbraith wrote:
> > > On Sun, 2018-01-07 at 11:18 +0100, Michal Hocko wrote:
> > > > On Sun 07-01-18 10:11:15, Greg KH wrote:
> > > > > On Sun, Jan 07, 2018 at 06:14:22AM +0100, Mike Galbraith wrote:
> > > > > > On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > > > > > > 4.14-stable review patch.  If anyone has any objections, plea=
se let me know.
> > > > > >=20
> > > > > > FYI, this broke kdump, or rather the makedumpfile part thereof.
> > > > > > =A0Forward looking wreckage is par for the kdump course, but...
> > > > >=20
> > > > > Is it also broken in Linus's tree with this patch?  Or is there a=
n
> > > > > add-on patch that I should apply to 4.14 to resolve this issue th=
ere?
> > > >=20
> > > > This one http://lkml.kernel.org/r/1513932498-20350-1-git-send-email=
-bhe@redhat.com
> > > > I guess.
> > >=20
> > > That won't unbreak kdump, else master wouldn't be broken. =A0I don't =
care
> > > deeply, or know if anyone else does, I'm just reporting it because I
> > > met it and chased it down.
> >=20
> > OK, I didn't notice that d8cfbbfa0f7 ("mm/sparse.c: wrong allocation
> > for mem_section") made it in after rc6. I am still wondering why
> > 83e3c48729 ("mm/sparsemem: Allocate mem_section at runtime for
> > CONFIG_SPARSEMEM_EXTREME=3Dy") made it into the stable tree in the firs=
t
> > place.
>=20
> It was part of the prep for the KTPI code from what I can tell.  If you
> think it should be reverted, just let me know and I'll be glad to do so.

No preference here. =A0I have to patch master regardless if I want kdump
to work while I patiently wait for userspace to get fixed up (either
that or use time I don't have to go fix it up myself).

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
