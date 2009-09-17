Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F1986B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 10:16:53 -0400 (EDT)
Received: by bwz24 with SMTP id 24so46004bwz.38
        for <linux-mm@kvack.org>; Thu, 17 Sep 2009 07:16:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4AB1A8FD.2010805@gmail.com>
References: <cover.1251388414.git.mst@redhat.com> <4AAFF437.7060100@gmail.com>
	 <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com>
	 <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com>
	 <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com>
	 <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com>
Date: Thu, 17 Sep 2009 09:16:56 -0500
Message-ID: <90eb1dc70909170716i5de0b909tf69c93e679f5fbc8@mail.gmail.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
From: Javier Guerra <javier@guerrag.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 10:11 PM, Gregory Haskins
<gregory.haskins@gmail.com> wrote:
>=C2=A0It is certainly not a requirement to make said
> chip somehow work with existing drivers/facilities on bare metal, per
> se. =C2=A0Why should virtual systems be different?

i'd guess it's an issue of support resources.  a hardware developer
creates a chip and immediately sells it, getting small but assured
revenue, with it they write (or pays to write) drivers for a couple of
releases, and stop to manufacture it as soon as it's not profitable.

software has a much longer lifetime, especially at the platform-level
(and KVM is a platform for a lot of us). also, being GPL, it's cheaper
to produce but has (much!) more limited resources.  creating a new
support issue is a scary thought.


--=20
Javier

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
