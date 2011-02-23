Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D1CD78D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 00:30:58 -0500 (EST)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Wed, 23 Feb 2011 13:29:24 +0800
Subject: RE: [0/7, v9] NUMA Hotplug Emulator (v9)
Message-ID: <749B9D3DBF0F054390025D9EAFF47F22333D016D@shsmsx501.ccr.corp.intel.com>
References: <20101210073119.156388875@intel.com>
 <alpine.DEB.2.00.1102221429030.31758@chino.kir.corp.google.com>
 <4D647F1D.2000307@linux.intel.com>
In-Reply-To: <4D647F1D.2000307@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haicheng Li <haicheng.li@linux.intel.com>, David Rientjes <rientjes@google.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, "You, Yongkang" <yongkang.you@intel.com>

I am rebasing the patch now. I will send out it when i finish.

best regards
yang


> -----Original Message-----
> From: Haicheng Li [mailto:haicheng.li@linux.intel.com]
> Sent: Wednesday, February 23, 2011 11:30 AM
> To: David Rientjes
> Cc: Zheng, Shaohui; Andrew Morton; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org; lethal@linux-sh.org; Andi Kleen;
> dave@linux.vnet.ibm.com; Greg Kroah-Hartman; Zhang, Yang Z; You, Yongkang
> Subject: Re: [0/7, v9] NUMA Hotplug Emulator (v9)
>=20
> Shaohui is out of position recently. Include Yang Zhang and Yongkang You =
in
> this loop, who are Shaohui's backup.
>=20
> David Rientjes wrote:
> > On Fri, 10 Dec 2010, shaohui.zheng@intel.com wrote:
> >
> >> v9:
> >>
> >> Solve the bug reported by Eric B Munson, check the return value of
> cpu_down when do
> >>  CPU release.
> >>
> >> Solve the conflicts with Tejun Heo' Unificaton NUMA code, re-work patc=
h 5
> based on his
> >> patch.
> >>
> >> Some small changes on debugfs per-node add_memory interface.
> >>
> >
> > Hi Shaohui,
> >
> > Tejun's NUMA unification work has been merged into x86/mm, so I think i=
t
> > would possible to rebase your hotplug emulator patchset on top of it
> > without too many conflicts now.
> >
> > It should probably be based on x86/mm from
> > http://git.kernel.org/?p=3Dlinux/kernel/git/mingo/linux-2.6-x86.git
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
