Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A96406B000E
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:39:36 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b76-v6so13564193ywb.11
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:39:36 -0700 (PDT)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730057.outbound.protection.outlook.com. [40.107.73.57])
        by mx.google.com with ESMTPS id e133-v6si18666043ybc.161.2018.11.01.03.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 03:39:35 -0700 (PDT)
From: "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>
Subject: RE: [PATCH] x86/build: Build VSMP support only if selected
Date: Thu, 1 Nov 2018 10:39:32 +0000
Message-ID: 
 <SN6PR15MB2366D7688B41535AF0A331F9C3CE0@SN6PR15MB2366.namprd15.prod.outlook.com>
References: <20181030230905.xHZmM%akpm@linux-foundation.org>
 <9e14d183-55a4-8299-7a18-0404e50bf004@infradead.org>
 <alpine.DEB.2.21.1811011032190.1642@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1811011032190.1642@nanos.tec.linutronix.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, Ravikiran Thirumalai <kiran@scalemp.com>, X86 ML <x86@kernel.org>, "'Eial Czerwacki (eial@scalemp.com)'" <eial@scalemp.com>, 'Oren Twaig' <oren@scalemp.com>

On 01/11/18 11:37, Thomas Gleixner wrote:

> VSMP support is built even if CONFIG_X86_VSMP is not set. This leads to a=
 build
> breakage when CONFIG_PCI is disabled as well.
>=20
> Build VSMP code only when selected.

This patch disables detect_vsmp_box() on systems without CONFIG_X86_VSMP, d=
ue to
the recent 6da63eb241a05b0e676d68975e793c0521387141.  This is significant
regression that will affect significant number of deployments.

We will reply shortly with an updated patch that fix the dependency on pv_i=
rq_ops,
and revert to CONFIG_PARAVIRT, with proper protection for CONFIG_PCI.
