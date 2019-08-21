Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE73AC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:18:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B4BB216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:18:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B4BB216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 268296B02E9; Wed, 21 Aug 2019 11:18:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2197A6B02EA; Wed, 21 Aug 2019 11:18:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12ECE6B02EB; Wed, 21 Aug 2019 11:18:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id E68596B02E9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:18:49 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 97E198123
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:18:49 +0000 (UTC)
X-FDA: 75846792378.01.place04_69fca86349653
X-HE-Tag: place04_69fca86349653
X-Filterd-Recvd-Size: 4313
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:18:48 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Aug 2019 08:18:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,412,1559545200"; 
   d="scan'208";a="169443350"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by orsmga007.jf.intel.com with ESMTP; 21 Aug 2019 08:18:46 -0700
Date: Wed, 21 Aug 2019 08:18:46 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Cc: Nicusor CITU <ncitu@bitdefender.com>,
	Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>,
	"Zhang@vger.kernel.org" <Zhang@vger.kernel.org>,
	Yu C <yu.c.zhang@intel.com>
Subject: Re: [RFC PATCH v6 55/92] kvm: introspection: add KVMI_CONTROL_MSR
 and KVMI_EVENT_MSR
Message-ID: <20190821151846.GD29345@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-56-alazar@bitdefender.com>
 <20190812210501.GD1437@linux.intel.com>
 <f9e94e9649f072911cc20129c2b633747d5c1df5.camel@bitdefender.com>
 <20190819183643.GB1916@linux.intel.com>
 <6854bfcc2bff3ffdaadad8708bd186a071ad682c.camel@bitdefender.com>
 <72df8b3ea66bb5bc7bb9c17e8bf12e12320358e1.camel@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <72df8b3ea66bb5bc7bb9c17e8bf12e12320358e1.camel@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 02:43:32PM +0300, Mihai Don=C8=9Bu wrote:
> On Tue, 2019-08-20 at 08:44 +0000, Nicusor CITU wrote:
> > > > > > +static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigne=
d
> > > > > > int
> > > > > > msr,
> > > > > > +			      bool enable)
> > > > > > +{
> > > > > > +	struct vcpu_vmx *vmx =3D to_vmx(vcpu);
> > > > > > +	unsigned long *msr_bitmap =3D vmx->vmcs01.msr_bitmap;
> > >=20
> > > Is KVMI intended to play nice with nested virtualization? Unconditi=
onally
> > > updating vmcs01.msr_bitmap is correct regardless of whether the vCP=
U
> > > is in L1 or L2, but if the vCPU is currently in L2 then the effecti=
ve
> > > bitmap, i.e. vmcs02.msr_bitmap, won't be updated until the next nes=
ted VM-
> > > Enter.
> >=20
> > Our initial proof of concept was running with success in nested
> > virtualization. But most of our tests were done on bare-metal.
> > We do however intend to make it fully functioning on nested systems
> > too.
> >=20
> > Even thought, from KVMI point of view, the MSR interception
> > configuration would be just fine if it gets updated before the vcpu i=
s
> > actually entering to nested VM.
> >=20
>=20
> I believe Sean is referring here to the case where the guest being
> introspected is a hypervisor (eg. Windows 10 with device guard).

Yep.

> Even though we are looking at how to approach this scenario, the
> introspection tools we have built will refuse to attach to a
> hypervisor.

In that case, it's probably a good idea to make KVMI mutually exclusive
with nested virtualization.  Doing so should, in theory, simplify the
implementation and expedite upstreaming, e.g. reviewers don't have to
nitpick edge cases related to nested virt.  My only hesitation in
disabling KVMI when nested virt is enabled is that it could make it much
more difficult to (re)enable the combination in the future.

