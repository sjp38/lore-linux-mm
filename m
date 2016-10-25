Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08C3D6B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:24:56 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so20776367pac.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:24:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y63si18216463pfd.11.2016.10.24.18.24.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 18:24:55 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 3/7] mm: add a function to get the max
 pfn
Date: Tue, 25 Oct 2016 01:24:47 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FB527@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-4-git-send-email-liang.z.li@intel.com>
 <580E3C76.3010205@intel.com>
In-Reply-To: <580E3C76.3010205@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

> On 10/20/2016 11:24 PM, Liang Li wrote:
> > Expose the function to get the max pfn, so it can be used in the
> > virtio-balloon device driver. Simply include the 'linux/bootmem.h'
> > is not enough, if the device driver is built to a module, directly
> > refer the max_pfn lead to build failed.
>=20
> I'm not sure the rest of the set is worth reviewing.  I think a lot of it=
 will
> change pretty fundamentally once you have those improved data structures
> in place.

That's true. I will send out the v4 as soon as possible.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
