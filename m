Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFC86B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 03:36:25 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id td3so35301777pab.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 00:36:25 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ku4si4491790pab.153.2016.03.10.00.36.24
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 00:36:24 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Thu, 10 Mar 2016 08:36:14 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
In-Reply-To: <20160310075728.GB4678@grmbl.mre>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Shah <amit.shah@redhat.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> >  Could provide more information on how to use virtio-serial to exchange
> data?  Thread , Wiki or code are all OK.
> >  I have not find some useful information yet.
>=20
> See this commit in the Linux sources:
>=20
> 108fc82596e3b66b819df9d28c1ebbc9ab5de14c
>=20
> that adds a way to send guest trace data over to the host.  I think that'=
s the
> most relevant to your use-case.  However, you'll have to add an in-kernel
> user of virtio-serial (like the virtio-console code
> -- the code that deals with tty and hvc currently).  There's no other non=
-tty
> user right now, and this is the right kind of use-case to add one for!
>=20
> For many other (userspace) use-cases, see the qemu-guest-agent in the
> qemu sources.
>=20
> The API is documented in the wiki:
>=20
> http://www.linux-kvm.org/page/Virtio-serial_API
>=20
> and the feature pages have some information that may help as well:
>=20
> https://fedoraproject.org/wiki/Features/VirtioSerial
>=20
> There are some links in here too:
>=20
> http://log.amitshah.net/2010/09/communication-between-guests-and-
> hosts/
>=20
> Hope this helps.
>=20
>=20
> 		Amit

Thanks a lot !!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
