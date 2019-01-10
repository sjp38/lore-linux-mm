Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9837F8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:40:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t72so8900318pfi.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:40:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w17si14229636pgl.6.2019.01.10.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:40:07 -0800 (PST)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [v5 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Date: Thu, 10 Jan 2019 23:40:01 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F5097E16F8E2@fmsmsx121.amr.corp.intel.com>
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190110153147.1baf4c88bf0dd3b8a78aad08@linux-foundation.org>
In-Reply-To: <20190110153147.1baf4c88bf0dd3b8a78aad08@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, "minchan@kernel.org" <minchan@kernel.org>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> >
> > +	if (si->flags & (SWP_BLKDEV | SWP_FS)) {
>=20
> I re-read your discussion with Tim and I must say the reasoning behind th=
is
> test remain foggy.

I was worried that the dereference

inode =3D si->swap_file->f_mapping->host;

is not always safe for corner cases.

So the test makes sure that the dereference is valid.

>=20
> What goes wrong if we just remove it?

If the dereference to get inode is always safe, we can remove it.


Thanks.

Tim
