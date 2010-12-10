Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A4886B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:35:30 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 10 Dec 2010 09:35:08 +0800
Subject: RE: [5/7,v8] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED661@shsmsx502.ccr.corp.intel.com>
References: <20101207010033.280301752@intel.com>
 <20101207010140.092555703@intel.com>
 <alpine.DEB.2.00.1012081334160.15658@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1012081334160.15658@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Ingo Molnar <mingo@elte.hu>, "Brown, Len" <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@sun.com>, "Li, Haicheng" <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Both Tejun's and my patches are under review process, the hotplug emulator =
patchset is much earlier than Tejun's patch. Currently, I did not know how =
to handle this situation.

It seems that I have 3 options:
1) continue to send this patchset based on current upstream kernel =20
2) continue to send this patchset based on upstream kernel + Tejun's patch
3) Postpone the patchset until Tejun's patches are accepted.

Can someone provide some suggestions? Thanks so much.

Thanks & Regards,
Shaohui


-----Original Message-----
From: David Rientjes [mailto:rientjes@google.com]=20
Sent: Thursday, December 09, 2010 5:37 AM
To: Zheng, Shaohui; Tejun Heo
Cc: Andrew Morton; linux-mm@kvack.org; linux-kernel@vger.kernel.org; haiche=
ng.li@linux.intel.com; lethal@linux-sh.org; Andi Kleen; dave@linux.vnet.ibm=
.com; Greg Kroah-Hartman; Ingo Molnar; Brown, Len; Yinghai Lu; Li, Haicheng
Subject: Re: [5/7,v8] NUMA Hotplug Emulator: Support cpu probe/release in x=
86_64

On Tue, 7 Dec 2010, shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
>=20

This patch is undoubtedly going to conflict with Tejun's unification of=20
the 32 and 64 bit NUMA boot paths, specifically the patch at=20
http://marc.info/?l=3Dlinux-kernel&m=3D129087151912379.

Tejun, what's the status of that patchset posted on November 27?  Any=20
comments about this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
