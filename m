Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5079F6B02F3
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:22:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id v2-v6so4606814ioh.17
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:22:25 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700125.outbound.protection.outlook.com. [40.107.70.125])
        by mx.google.com with ESMTPS id w1-v6si11985077iop.273.2018.08.16.11.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 11:22:24 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v3 3/4] mm/memory_hotplug: Refactor
 unregister_mem_sect_under_nodes
Date: Thu, 16 Aug 2018 18:22:21 +0000
Message-ID: <20180816182220.dmlun5edcbf4lspj@xakep.localdomain>
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-4-osalvador@techadventures.net>
 <20180815150121.7ec35ddabf18aea88d84437f@linux-foundation.org>
 <20180816074813.GA16221@techadventures.net>
In-Reply-To: <20180816074813.GA16221@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D33BD405BF53E24FB8DD25B72AF4ABD6@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "david@redhat.com" <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

> > d) What's the maximum number of nodes, ever?  Perhaps we can always
> >    fit a nodemask_t onto the stack, dunno.
>=20
> Right now, we define the maximum as NODES_SHIFT =3D 10, so:
>=20
> 1 << 10 =3D 1024 Maximum nodes.
>=20
> Since this makes only 128 bytes, I wonder if we can just go ahead and def=
ine a nodemask_t
> whithin the stack.
> 128 bytes is not that much, is it?

Yeah, sue stack here, 128b is tiny. This also will solve Andrew's point of =
having an untested path when alloc fails, and simplify the patch overall.

Thank you,
Pavel=
