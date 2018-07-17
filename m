Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB30B6B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 02:53:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d1-v6so16761pfo.16
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:53:32 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id s1-v6si208435pfi.369.2018.07.16.23.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 23:53:31 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v6 07/13] mm, madvise_inject_error: Let memory_failure()
 optionally take a page reference
Date: Tue, 17 Jul 2018 06:52:03 +0000
Message-ID: <20180717065203.GA28797@hori1.linux.bs1.fc.nec.co.jp>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154380652.34503.2174920161570183766.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154380652.34503.2174920161570183766.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <AA720C8AA8CD424B8103DFFF1357E029@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.com>, "hch@lst.de" <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 13, 2018 at 09:50:06PM -0700, Dan Williams wrote:
> The madvise_inject_error() routine uses get_user_pages() to lookup the
> pfn and other information for injected error, but it does not release
> that pin. The assumption is that failed pages should be taken out of
> circulation.
>=20
> However, for dax mappings it is not possible to take pages out of
> circulation since they are 1:1 physically mapped as filesystem blocks,
> or device-dax capacity. They also typically represent persistent memory
> which has an error clearing capability.
>=20
> In preparation for adding a special handler for dax mappings, shift the
> responsibility of taking the page reference to memory_failure(). I.e.
> drop the page reference and do not specify MF_COUNT_INCREASED to
> memory_failure().
>=20
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=
