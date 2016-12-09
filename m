Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E07F36B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 22:09:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so11875711pgq.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 19:09:51 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 129si31531510pfx.1.2016.12.08.19.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 19:09:50 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Fri, 9 Dec 2016 03:09:47 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A14D246@SHSMSX104.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <f7b47cc4-ee94-bacb-5a17-d049b402263e@intel.com>
In-Reply-To: <f7b47cc4-ee94-bacb-5a17-d049b402263e@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast (de)inf=
lating
> & fast live migration
>=20
> On 12/07/2016 05:35 AM, Li, Liang Z wrote:
> >> Am 30.11.2016 um 09:43 schrieb Liang Li:
> >> IOW in real examples, do we have really large consecutive areas or
> >> are all pages just completely distributed over our memory?
> >
> > The buddy system of Linux kernel memory management shows there
> should
> > be quite a lot of consecutive pages as long as there are a portion of
> > free memory in the guest.
> ...
> > If all pages just completely distributed over our memory, it means the
> > memory fragmentation is very serious, the kernel has the mechanism to
> > avoid this happened.
>=20
> While it is correct that the kernel has anti-fragmentation mechanisms, I =
don't
> think it invalidates the question as to whether a bitmap would be too spa=
rse
> to be effective.
>=20
> > In the other hand, the inflating should not happen at this time
> > because the guest is almost 'out of memory'.
>=20
> I don't think this is correct.  Most systems try to run with relatively l=
ittle free
> memory all the time, using the bulk of it as page cache.  We have no reas=
on
> to expect that ballooning will only occur when there is lots of actual fr=
ee
> memory and that it will not occur when that same memory is in use as page
> cache.
>=20

Yes.
> In these patches, you're effectively still sending pfns.  You're just sen=
ding
> one pfn per high-order page which is giving a really nice speedup.  IMNHO=
,
> you're avoiding doing a real bitmap because creating a bitmap means eithe=
r
> have a really big bitmap, or you would have to do some sorting (or multip=
le
> passes) of the free lists before populating a smaller bitmap.
>=20
> Like David, I would still like to see some data on whether the choice bet=
ween
> bitmaps and pfn lists is ever clearly in favor of bitmaps.  You haven't
> convinced me, at least, that the data isn't even worth collecting.

I will try to get some data with the real workload and share it with your g=
uys.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
