Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553A2C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:27:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 232752089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:27:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 232752089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B359D6B026F; Tue, 10 Sep 2019 12:27:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE62D6B0270; Tue, 10 Sep 2019 12:27:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A22246B0271; Tue, 10 Sep 2019 12:27:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5ED6B026F
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:27:55 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2A526181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:27:55 +0000 (UTC)
X-FDA: 75919542510.20.part63_7f45d1d37e734
X-HE-Tag: part63_7f45d1d37e734
X-Filterd-Recvd-Size: 3913
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:27:54 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 5CA3A307483A;
	Tue, 10 Sep 2019 19:27:52 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3C3B8303A562;
	Tue, 10 Sep 2019 19:27:52 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 69/92] kvm: x86: keep the page protected if tracked
 by the introspection tool
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org, Paolo Bonzini
	<pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>,
	Tamas K Lengyel <tamas@tklengyel.com>, Mathieu Tarral
	<mathieu.tarral@protonmail.com>, Samuel =?iso-8859-1?q?Laur=E9n?=
	<samuel.lauren@iki.fi>, Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka
	<jan.kiszka@siemens.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Yu C
	<yu.c.zhang@intel.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>
In-Reply-To: <20190910142642.GC5879@char.us.oracle.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-70-alazar@bitdefender.com>
	<20190910142642.GC5879@char.us.oracle.com>
Date: Tue, 10 Sep 2019 19:28:19 +0300
Message-ID: <15681328990.F582D7fCB.15355@host>
User-agent: void
Content-Type: text/plain; charset=UTF-8
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Sep 2019 10:26:42 -0400, Konrad Rzeszutek Wilk <konrad.wilk@or=
acle.com> wrote:
> On Fri, Aug 09, 2019 at 07:00:24PM +0300, Adalbert Laz=C4=83r wrote:
> > This patch might be obsolete thanks to single-stepping.
>=20
> sooo should it be skipped from this large patchset to easy
> review?

I'll add a couple of warning messages to check if this patch is still
needed, in order to skip it from the next submission (which will be small=
er:)

However, on AMD, single-stepping is not an option.

Thanks,
Adalbert

>=20
> >=20
> > Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> > ---
> >  arch/x86/kvm/x86.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index 2c06de73a784..06f44ce8ed07 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -6311,7 +6311,8 @@ static bool reexecute_instruction(struct kvm_vc=
pu *vcpu, gva_t cr2,
> >  		indirect_shadow_pages =3D vcpu->kvm->arch.indirect_shadow_pages;
> >  		spin_unlock(&vcpu->kvm->mmu_lock);
> > =20
> > -		if (indirect_shadow_pages)
> > +		if (indirect_shadow_pages
> > +		    && !kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
> >  			kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
> > =20
> >  		return true;
> > @@ -6322,7 +6323,8 @@ static bool reexecute_instruction(struct kvm_vc=
pu *vcpu, gva_t cr2,
> >  	 * and it failed try to unshadow page and re-enter the
> >  	 * guest to let CPU execute the instruction.
> >  	 */
> > -	kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
> > +	if (!kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
> > +		kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
> > =20
> >  	/*
> >  	 * If the access faults on its page table, it can not
> > @@ -6374,6 +6376,9 @@ static bool retry_instruction(struct x86_emulat=
e_ctxt *ctxt,
> >  	if (!vcpu->arch.mmu->direct_map)
> >  		gpa =3D kvm_mmu_gva_to_gpa_write(vcpu, cr2, NULL);
> > =20
> > +	if (kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
> > +		return false;
> > +
> >  	kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
> > =20
> >  	return true;

