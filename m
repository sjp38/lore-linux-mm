Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4A66B0278
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 07:44:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n13so2908470wmc.3
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 04:44:13 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id b134si6494715wme.35.2018.01.07.04.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jan 2018 04:44:12 -0800 (PST)
Message-ID: <1515329042.13953.14.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 07 Jan 2018 13:44:02 +0100
In-Reply-To: <20180107101847.GC24862@dhcp22.suse.cz>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de> <20180107091115.GB29329@kroah.com>
	 <20180107101847.GC24862@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Sun, 2018-01-07 at 11:18 +0100, Michal Hocko wrote:
> On Sun 07-01-18 10:11:15, Greg KH wrote:
> > On Sun, Jan 07, 2018 at 06:14:22AM +0100, Mike Galbraith wrote:
> > > On Fri, 2017-12-22 at 09:45 +0100, Greg Kroah-Hartman wrote:
> > > > 4.14-stable review patch.  If anyone has any objections, please let=
 me know.
> > >=20
> > > FYI, this broke kdump, or rather the makedumpfile part thereof.
> > > =A0Forward looking wreckage is par for the kdump course, but...
> >=20
> > Is it also broken in Linus's tree with this patch?  Or is there an
> > add-on patch that I should apply to 4.14 to resolve this issue there?
>=20
> This one http://lkml.kernel.org/r/1513932498-20350-1-git-send-email-bhe@r=
edhat.com
> I guess.

That won't unbreak kdump, else master wouldn't be broken. =A0I don't care
deeply, or know if anyone else does, I'm just reporting it because I
met it and chased it down.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
