Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2830C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8596920651
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:06:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8596920651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5DB6B0006; Tue, 13 Aug 2019 12:06:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15F7A6B0007; Tue, 13 Aug 2019 12:06:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DD76B0008; Tue, 13 Aug 2019 12:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id D36166B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:06:18 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4F75E180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:06:18 +0000 (UTC)
X-FDA: 75817881636.13.sleet28_36f95d8160731
X-HE-Tag: sleet28_36f95d8160731
X-Filterd-Recvd-Size: 3429
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:06:17 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 818B830644BA;
	Tue, 13 Aug 2019 19:06:16 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 6D9C1303EF04;
	Tue, 13 Aug 2019 19:06:16 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 70/92] kvm: x86: filter out access rights only when
 tracked by the introspection tool
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>
In-Reply-To: <8cba6816-8d3a-2498-b3b0-2ce76a98ce12@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-71-alazar@bitdefender.com>
	<8cba6816-8d3a-2498-b3b0-2ce76a98ce12@redhat.com>
Date: Tue, 13 Aug 2019 19:06:43 +0300
Message-ID: <1565712403.bf0eBF.11721.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 11:08:39 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
> > It should complete the commit fd34a9518173 ("kvm: x86: consult the pa=
ge tracking from kvm_mmu_get_page() and __direct_map()")
> >=20
> > Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> > ---
> >  arch/x86/kvm/mmu.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >=20
> > diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> > index 65b6acba82da..fd64cf1115da 100644
> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -2660,6 +2660,9 @@ static void clear_sp_write_flooding_count(u64 *=
spte)
> >  static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gf=
n_t gfn,
> >  					   unsigned int acc)
> >  {
> > +	if (!kvmi_tracked_gfn(vcpu, gfn))
> > +		return acc;
> > +
> >  	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
> >  		acc &=3D ~ACC_USER_MASK;
> >  	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
> >=20
>=20
> If this patch is always needed, then the function should be named
> something like kvm_mmu_apply_introspection_access and kvmi_tracked_gfn
> should be tested from the moment it is introduced.
>=20
> But the commit message says nothing about _why_ it is needed, so I
> cannot guess.  I would very much avoid it however.  Is it just an
> optimization?
>=20
> Paolo

We'll retest to see if we still need kvm_mmu_page_track_acc().
The kvmi_tracked_gfn() check was used to keep the KVM code flow
"unchanged" as much as possible. Probably, we can get ride of it.

