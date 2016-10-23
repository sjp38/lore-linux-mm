Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD32F6B0069
	for <linux-mm@kvack.org>; Sun, 23 Oct 2016 07:29:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so98593492pfj.6
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 04:29:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o5si10744109pgh.134.2016.10.23.04.29.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 23 Oct 2016 04:29:29 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Sun, 23 Oct 2016 11:29:25 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0F9FA3@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com> <20161021224428-mutt-send-email-mst@kernel.org>
In-Reply-To: <20161021224428-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> On Fri, Oct 21, 2016 at 10:25:21AM -0700, Dave Hansen wrote:
> > On 10/20/2016 11:24 PM, Liang Li wrote:
> > > Dave Hansen suggested a new scheme to encode the data structure,
> > > because of additional complexity, it's not implemented in v3.
> >
> > So, what do you want done with this patch set?  Do you want it applied
> > as-is so that we can introduce a new host/guest ABI that we must
> > support until the end of time?  Then, we go back in a year or two and
> > add the newer format that addresses the deficiencies that this ABI has
> > with a third version?
> >
>=20
> Exactly my questions.

Hi Dave & Michael,

In the V2, both of you thought that the memory I allocated for the bitmap i=
s too large, and gave some
 suggestions about the solution, so I changed the implementation and used  =
scattered pages for the bitmap
instead of a large physical continued memory. I didn't get the comments abo=
ut the changes, so I am not=20
sure whether that is OK or not, that's the why I resend the V3, I just want=
 your opinions about that part.=20

I will implement the new schema as Dave suggested in V4. Before that, could=
 you take a look at this version and
give some comments?=20

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
