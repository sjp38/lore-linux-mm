Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 324896B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:48:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so31661011pfg.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:48:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xq3si9893980pac.194.2016.07.27.20.48.20
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 20:48:20 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Date: Thu, 28 Jul 2016 03:48:16 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213E86@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <20160728010616-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728010616-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> > +/*
> > + * VIRTIO_BALLOON_PFNS_LIMIT is used to limit the size of page bitmap
> > + * to prevent a very large page bitmap, there are two reasons for this=
:
> > + * 1) to save memory.
> > + * 2) allocate a large bitmap may fail.
> > + *
> > + * The actual limit of pfn is determined by:
> > + * pfn_limit =3D min(max_pfn, VIRTIO_BALLOON_PFNS_LIMIT);
> > + *
> > + * If system has more pages than VIRTIO_BALLOON_PFNS_LIMIT, we will
> > +scan
> > + * the page list and send the PFNs with several times. To reduce the
> > + * overhead of scanning the page list. VIRTIO_BALLOON_PFNS_LIMIT
> > +should
> > + * be set with a value which can cover most cases.
> > + */
> > +#define VIRTIO_BALLOON_PFNS_LIMIT ((32 * (1ULL << 30)) >>
> PAGE_SHIFT)
> > +/* 32GB */
> > +
> >  static int oom_pages =3D OOM_VBALLOON_DEFAULT_PAGES;
> > module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> > MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> >
> > +extern unsigned long get_max_pfn(void);
> > +
>=20
> Please just include the correct header. No need for this hackery.
>=20

Will change. Thanks!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
