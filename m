Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 021926B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 02:48:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r9-v6so6287064pgp.12
        for <linux-mm@kvack.org>; Tue, 22 May 2018 23:48:25 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id n6-v6si17612364pfi.360.2018.05.22.23.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 23:48:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 09/11] mm, memory_failure: pass page size to kill_proc()
Date: Wed, 23 May 2018 06:41:23 +0000
Message-ID: <20180523064123.GA22463@hori1.linux.bs1.fc.nec.co.jp>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152700001949.24093.5303974728568066054.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152700001949.24093.5303974728568066054.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1566589E8E7F89458BB8DF6F18C4B147@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "hch@lst.de" <hch@lst.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>

On Tue, May 22, 2018 at 07:40:19AM -0700, Dan Williams wrote:
> Given that ZONE_DEVICE / dev_pagemap pages are never assembled into
> compound pages, the size determination logic in kill_proc() needs
> updating for the dev_pagemap case. In preparation for dev_pagemap
> support rework memory_failure() and kill_proc() to pass / consume the pag=
e
> size explicitly.
>=20
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=
