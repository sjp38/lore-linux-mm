Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2172F6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 23:35:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so45450781pgc.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 20:35:46 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g21si22610121pgj.268.2017.02.03.20.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 20:35:45 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Date: Sat, 4 Feb 2017 04:35:41 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C363988@shsmsx102.ccr.corp.intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
 <20170120114809.GH2658@work-vm>
In-Reply-To: <20170120114809.GH2658@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

> <snip>
>=20
> > +static void free_extended_page_bitmap(struct virtio_balloon *vb) {
> > +	int i, bmap_count =3D vb->nr_page_bmap;
> > +
> > +	for (i =3D 1; i < bmap_count; i++) {
> > +		kfree(vb->page_bitmap[i]);
> > +		vb->page_bitmap[i] =3D NULL;
> > +		vb->nr_page_bmap--;
> > +	}
> > +}
> > +
> > +static void kfree_page_bitmap(struct virtio_balloon *vb) {
> > +	int i;
> > +
> > +	for (i =3D 0; i < vb->nr_page_bmap; i++)
> > +		kfree(vb->page_bitmap[i]);
> > +}
>=20
> It might be worth commenting that pair of functions to make it clear why
> they are so different; I guess the kfree_page_bitmap is used just before =
you
> free the structure above it so you don't need to keep the count/pointers
> updated?
>=20

Yes. I will add some comments for that. Thanks!

Liang
=20
> Dave
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
