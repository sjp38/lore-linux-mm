Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC4488E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:40:30 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 68so165904pfr.6
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:40:30 -0800 (PST)
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690072.outbound.protection.outlook.com. [40.107.69.72])
        by mx.google.com with ESMTPS id w189si143845pfb.151.2018.12.12.15.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Dec 2018 15:40:29 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 2/4] modules: Add new special vfree flags
Date: Wed, 12 Dec 2018 23:40:25 +0000
Message-ID: <3AD9DBCA-C6EC-4FA6-84DC-09F3D4A9C47B@vmware.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-3-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-3-rick.p.edgecombe@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <ADD48BCB096691449093B6E0F0AE63DE@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "deneen.t.dock@intel.com" <deneen.t.dock@intel.com>

> On Dec 11, 2018, at 4:03 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> =
wrote:
>=20
> Add new flags for handling freeing of special permissioned memory in vmal=
loc,
> and remove places where the handling was done in module.c.
>=20
> This will enable this flag for all architectures.
>=20
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
> kernel/module.c | 43 ++++++++++++-------------------------------
> 1 file changed, 12 insertions(+), 31 deletions(-)
>=20

I count on you for merging your patch-set with mine, since clearly they
conflict.
