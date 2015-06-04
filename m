Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D8244900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 13:14:42 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so34924012pdb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 10:14:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bo11si1847590pdb.19.2015.06.04.10.14.41
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 10:14:42 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 12/12] mm: let slab/slub/slob use mirrored memory
Date: Thu, 4 Jun 2015 17:14:38 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8D5D7@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704D15.3030309@huawei.com>
In-Reply-To: <55704D15.3030309@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

-	page =3D alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gf=
porder);
+	page =3D alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK | __GFP_MIR=
ROR,
+					cachep->gfporder);
=20
Set some global "got_mirror"[*] if we have any mirrored memory to __GFP_MIR=
ROR, else to 0.

then
=09
	page =3D alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK | got_mirror=
,
					cachep->gfporder);

-Tony

[*] Someone will suggest a better name. I'm bad at picking names.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
