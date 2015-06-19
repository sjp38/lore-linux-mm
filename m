Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFE86B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:42:43 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so37412344pdb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:42:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id re6si17627947pab.88.2015.06.19.11.42.41
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 11:42:41 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
Date: Fri, 19 Jun 2015 18:42:39 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A9E82F@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz>
 <557FDB9B.1090105@huawei.com> <557FF06A.3020000@suse.cz>
 <55821D85.3070208@huawei.com> <55825DF0.9090903@suse.cz>
 <55829149.60807@huawei.com> <5582959E.4080402@suse.cz>
 <20150618203335.GA3829@agluck-desk.sc.intel.com>
 <55837224.2090702@huawei.com>
In-Reply-To: <55837224.2090702@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> What's your suggestions? a new zone or a new migratetype?
> Maybe add a new zone will change more mm code.

I don't understand this code well enough (yet) to make a recommendation.  I=
 think
our primary concern may not be "how much code we change", but more "how can
we minimize the run-time impact on systems that don't have any mirrored mem=
ory.

Just putting all the heavy work behind a CONFIG option isn't sufficient ...=
 we want
enterprise distributions to ship with the option turned on ... even though =
most
machines won't be using this feature.

-Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
