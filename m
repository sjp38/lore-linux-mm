Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5BE18E0006
	for <linux-mm@kvack.org>; Sun, 16 Sep 2018 23:07:52 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z72-v6so11685792itc.8
        for <linux-mm@kvack.org>; Sun, 16 Sep 2018 20:07:52 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0113.outbound.protection.outlook.com. [104.47.38.113])
        by mx.google.com with ESMTPS id a4-v6si7968517ioc.119.2018.09.16.20.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 16 Sep 2018 20:07:51 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: [PATCH AUTOSEL 3.18 03/29] x86/numa_emulation: Fix
 emulated-to-physical node mapping
Date: Mon, 17 Sep 2018 03:05:38 +0000
Message-ID: <20180917030533.592-3-alexander.levin@microsoft.com>
References: <20180917030533.592-1-alexander.levin@microsoft.com>
In-Reply-To: <20180917030533.592-1-alexander.levin@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Wei Yang <richard.weiyang@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>

From: Dan Williams <dan.j.williams@intel.com>

[ Upstream commit 3b6c62f363a19ce82bf378187ab97c9dc01e3927 ]

Without this change the distance table calculation for emulated nodes
may use the wrong numa node and report an incorrect distance.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/153089328103.27680.14778434392225818887.stgi=
t@dwillia2-desk3.amr.corp.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 arch/x86/mm/numa_emulation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index a8f90ce3dedf..dc6d99017f3f 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -60,7 +60,7 @@ static int __init emu_setup_memblk(struct numa_meminfo *e=
i,
 	eb->nid =3D nid;
=20
 	if (emu_nid_to_phys[nid] =3D=3D NUMA_NO_NODE)
-		emu_nid_to_phys[nid] =3D nid;
+		emu_nid_to_phys[nid] =3D pb->nid;
=20
 	pb->start +=3D size;
 	if (pb->start >=3D pb->end) {
--=20
2.17.1
