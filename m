Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F6996B0088
	for <linux-mm@kvack.org>; Tue, 28 Dec 2010 21:31:36 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Wed, 29 Dec 2010 10:31:13 +0800
Subject: RE: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF2AEA91755F@shsmsx502.ccr.corp.intel.com>
References: <20101210073119.156388875@intel.com>
 <20101210073242.462037866@intel.com>
 <20101222162723.72075372.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1012272241200.23315@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1012272241200.23315@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, "Li,
 Haicheng" <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Tuesday, December 28, 2010 3:35 PM
> To: Zheng, Shaohui; Andrew Morton
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; haicheng.li@linux.i=
ntel.com; lethal@linux-sh.org; Andi Kleen;
> dave@linux.vnet.ibm.com; Greg Kroah-Hartman; Li, Haicheng
> Subject: Re: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
>=20
>=20
> Shaohui, I'll reply to this message with an updated version of this patch
> to address Andrew's comments.  You can merge it into your series or Andre=
w
> can take it seperately (although it doesn't do much good without "x86: ad=
d
> numa=3Dpossible command line option" unless you have hotpluggable SRAT
> entries and CONFIG_ACPI_NUMA).


Okay, thanks David. I will merge it into my series when I send next version=
