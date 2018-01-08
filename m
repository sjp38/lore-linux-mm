Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 355C96B0292
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 04:45:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so3436142wmd.5
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 01:45:42 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id z5si7925658wmd.88.2018.01.08.01.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 01:45:41 -0800 (PST)
Message-ID: <1515404732.7524.28.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 08 Jan 2018 10:45:32 +0100
In-Reply-To: <20180108083306.GA12893@kroah.com>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de> <20180107091115.GB29329@kroah.com>
	 <20180107101847.GC24862@dhcp22.suse.cz> <1515329042.13953.14.camel@gmx.de>
	 <20180107132309.GD24862@dhcp22.suse.cz> <20180108075308.GC24062@kroah.com>
	 <1515399333.20268.23.camel@gmx.de> <20180108083306.GA12893@kroah.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Mon, 2018-01-08 at 09:33 +0100, Greg Kroah-Hartman wrote:
> On Mon, Jan 08, 2018 at 09:15:33AM +0100, Mike Galbraith wrote:
>=20
> > > It was part of the prep for the KTPI code from what I can tell.  If y=
ou
> > > think it should be reverted, just let me know and I'll be glad to do =
so.
> >=20
> > No preference here. =A0I have to patch master regardless if I want kdum=
p
> > to work while I patiently wait for userspace to get fixed up (either
> > that or use time I don't have to go fix it up myself).
>=20
> I'll stay "bug compatible" for the time being.  If you do fix this up,
> can you add a cc: stable tag in your patch so I can pick it up when it
> gets merged?

Userspace (makedumpfile) will have to adapt, not the kernel. Meanwhile
I carry reverts, making kernels, kdump and myself all happy campers.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
