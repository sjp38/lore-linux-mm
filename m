Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAE066B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 13:32:17 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id u82so211876063ywc.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 10:32:17 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id k141si31297562itb.16.2016.09.06.10.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 10:32:17 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id y2so83853856oie.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 10:32:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DM2PR21MB00892878E2A17E076A18C795CBF90@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
 <DM2PR21MB00892878E2A17E076A18C795CBF90@DM2PR21MB0089.namprd21.prod.outlook.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Sep 2016 10:32:16 -0700
Message-ID: <CAPcyv4gZK33SH7FjZDYpkf-9peeZ0E3pZu=ZjmHwSBxdh4zj-g@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Toshi Kani <toshi.kani@hpe.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

On Tue, Sep 6, 2016 at 10:20 AM, Matthew Wilcox <mawilcox@microsoft.com> wr=
ote:
> I have no objection to this patch going in for now.
>
> Longer term, surely we want to track what mode the PFNs are mapped in?  T=
here are various bizarre suppositions out there about how persistent memory=
 should be mapped, and it's probably better if the kernel ignores what the =
user specifies and keeps everything sane.  I've read the dire warnings in t=
he Intel architecture manual and I have no desire to deal with the inevitab=
le bug reports on some hardware I don't own and requires twenty weeks of op=
eration in order to observe the bug.

Is there a way for userspace to establish mappings with different
cache modes, besides via /dev/mem?  That was the motivation for
CONFIG_IO_STRICT_DEVMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
