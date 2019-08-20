Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25D84C41514
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E895722D37
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:43:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E895722D37
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8781E6B0007; Tue, 20 Aug 2019 07:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 829706B0008; Tue, 20 Aug 2019 07:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7403C6B000A; Tue, 20 Aug 2019 07:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 51FC56B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:43:40 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 06C5D8248ABD
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:43:40 +0000 (UTC)
X-FDA: 75842621400.01.match55_3d0a25cc3094b
X-HE-Tag: match55_3d0a25cc3094b
X-Filterd-Recvd-Size: 3670
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:43:39 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp01.buh.bitdefender.com [10.17.80.75])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 1651E30644B8;
	Tue, 20 Aug 2019 14:43:37 +0300 (EEST)
Received: from [192.168.1.34] (unknown [146.66.138.137])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 30A373011E05;
	Tue, 20 Aug 2019 14:43:35 +0300 (EEST)
Message-ID: <72df8b3ea66bb5bc7bb9c17e8bf12e12320358e1.camel@bitdefender.com>
Subject: Re: [RFC PATCH v6 55/92] kvm: introspection: add KVMI_CONTROL_MSR
 and KVMI_EVENT_MSR
From: Mihai =?UTF-8?Q?Don=C8=9Bu?= <mdontu@bitdefender.com>
To: Nicusor CITU <ncitu@bitdefender.com>, Sean Christopherson
	 <sean.j.christopherson@intel.com>
Cc: Adalbert =?UTF-8?Q?Laz=C4=83r?= <alazar@bitdefender.com>, 
 "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,  "virtualization@lists.linux-foundation.org"
 <virtualization@lists.linux-foundation.org>, Paolo Bonzini
 <pbonzini@redhat.com>,  Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?=
 <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tamas
 K Lengyel <tamas@tklengyel.com>, Mathieu Tarral
 <mathieu.tarral@protonmail.com>, Samuel =?ISO-8859-1?Q?Laur=E9n?=
 <samuel.lauren@iki.fi>, Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka
 <jan.kiszka@siemens.com>, Stefan Hajnoczi <stefanha@redhat.com>, Weijiang
 Yang <weijiang.yang@intel.com>, "Zhang@vger.kernel.org"
 <Zhang@vger.kernel.org>,  Yu C <yu.c.zhang@intel.com>
Date: Tue, 20 Aug 2019 14:43:32 +0300
In-Reply-To: <6854bfcc2bff3ffdaadad8708bd186a071ad682c.camel@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	 <20190809160047.8319-56-alazar@bitdefender.com>
	 <20190812210501.GD1437@linux.intel.com>
	 <f9e94e9649f072911cc20129c2b633747d5c1df5.camel@bitdefender.com>
	 <20190819183643.GB1916@linux.intel.com>
	 <6854bfcc2bff3ffdaadad8708bd186a071ad682c.camel@bitdefender.com>
Organization: Bitdefender
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-20 at 08:44 +0000, Nicusor CITU wrote:
> > > > > +static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned
> > > > > int
> > > > > msr,
> > > > > +			      bool enable)
> > > > > +{
> > > > > +	struct vcpu_vmx *vmx =3D to_vmx(vcpu);
> > > > > +	unsigned long *msr_bitmap =3D vmx->vmcs01.msr_bitmap;
> >=20
> > Is KVMI intended to play nice with nested virtualization? Uncondition=
ally
> > updating vmcs01.msr_bitmap is correct regardless of whether the vCPU
> > is in L1 or L2, but if the vCPU is currently in L2 then the effective
> > bitmap, i.e. vmcs02.msr_bitmap, won't be updated until the next neste=
d VM-
> > Enter.
>=20
> Our initial proof of concept was running with success in nested
> virtualization. But most of our tests were done on bare-metal.
> We do however intend to make it fully functioning on nested systems
> too.
>=20
> Even thought, from KVMI point of view, the MSR interception
> configuration would be just fine if it gets updated before the vcpu is
> actually entering to nested VM.
>=20

I believe Sean is referring here to the case where the guest being
introspected is a hypervisor (eg. Windows 10 with device guard).

Even though we are looking at how to approach this scenario, the
introspection tools we have built will refuse to attach to a
hypervisor.

Regards,

--=20
Mihai Don=C8=9Bu



