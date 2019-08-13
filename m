Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BF9BC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:51:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8FDB20578
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:51:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8FDB20578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 611666B0005; Tue, 13 Aug 2019 08:51:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C2786B0006; Tue, 13 Aug 2019 08:51:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D8E56B0007; Tue, 13 Aug 2019 08:51:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDB96B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:51:11 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CFA0E181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:51:10 +0000 (UTC)
X-FDA: 75817389900.23.month24_618ac5718fd36
X-HE-Tag: month24_618ac5718fd36
X-Filterd-Recvd-Size: 5402
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:51:10 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E24D330644BA;
	Tue, 13 Aug 2019 15:51:07 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id C81D4305B7A0;
	Tue, 13 Aug 2019 15:51:07 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 64/92] kvm: introspection: add single-stepping
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org, Paolo Bonzini
	<pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tamas K Lengyel
	<tamas@tklengyel.com>, Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Zhang@linux.intel.com, Yu C
	<yu.c.zhang@intel.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	=?UTF-8?b?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, Jim Mattson
	<jmattson@google.com>, Joerg Roedel <joro@8bytes.org>
In-Reply-To: <20190812205038.GC1437@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-65-alazar@bitdefender.com>
	<20190812205038.GC1437@linux.intel.com>
Date: Tue, 13 Aug 2019 15:51:33 +0300
Message-ID: <1565700693.6410DC6Aa.12556.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 13:50:39 -0700, Sean Christopherson <sean.j.christoph=
erson@intel.com> wrote:
> On Fri, Aug 09, 2019 at 07:00:19PM +0300, Adalbert Laz=C4=83r wrote:
> > From: Nicu=C8=99or C=C3=AE=C8=9Bu <ncitu@bitdefender.com>
> >=20
> > This would be used either if the introspection tool request it as a
> > reply to a KVMI_EVENT_PF event or to cope with instructions that cann=
ot
> > be handled by the x86 emulator during the handling of a VMEXIT. In
> > these situations, all other vCPU-s are kicked and held, the EPT-based
> > protection is removed and the guest is single stepped by the vCPU tha=
t
> > triggered the initial VMEXIT. Upon completion the EPT-base protection
> > is reinstalled and all vCPU-s all allowed to return to the guest.
> >=20
> > This is a rather slow workaround that kicks in occasionally. In the
> > future, the most frequently single-stepped instructions should be add=
ed
> > to the emulator (usually, stores to and from memory - SSE/AVX).
> >=20
> > For the moment it works only on Intel.
> >=20
> > CC: Jim Mattson <jmattson@google.com>
> > CC: Sean Christopherson <sean.j.christopherson@intel.com>
> > CC: Joerg Roedel <joro@8bytes.org>
> > Signed-off-by: Nicu=C8=99or C=C3=AE=C8=9Bu <ncitu@bitdefender.com>
> > Co-developed-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> > Signed-off-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> > Co-developed-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> > Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> > ---
> >  arch/x86/include/asm/kvm_host.h |   3 +
> >  arch/x86/kvm/kvmi.c             |  47 ++++++++++-
> >  arch/x86/kvm/svm.c              |   5 ++
> >  arch/x86/kvm/vmx/vmx.c          |  17 ++++
> >  arch/x86/kvm/x86.c              |  19 +++++
> >  include/linux/kvmi.h            |   4 +
> >  virt/kvm/kvmi.c                 | 145 ++++++++++++++++++++++++++++++=
+-
> >  virt/kvm/kvmi_int.h             |  16 ++++
> >  8 files changed, 253 insertions(+), 3 deletions(-)
> >=20

[...] We'll do.

> > diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
> > index d7f9858d3e97..1550fe33ed48 100644
> > --- a/virt/kvm/kvmi_int.h
> > +++ b/virt/kvm/kvmi_int.h
> > @@ -126,6 +126,9 @@ struct kvmi_vcpu {
> >  		DECLARE_BITMAP(high, KVMI_NUM_MSR);
> >  	} msr_mask;
> > =20
> > +	bool ss_owner;
>=20
> Why is single-stepping mutually exclusive across all vCPUs?  Does that
> always have to be the case?

I never thought to single-step multiple vCPUs in the same time.

If one vCPU will relax the access to a guest page while a second one,
finishing single-stepping, restores the 'r--' flags, the first one
will get another page fault and relax the page access again. It might
be doable, but before starting single-stepping a vCPU we might replace
guest memory (as requested by the introspection tool) and we will have
to use a lock for this.

However, we would like to use alternate EPT views with single-step.
So, we might replace this patch.

> > +	bool ss_requested;
> > +
> >  	struct list_head job_list;
> >  	spinlock_t job_lock;
> > =20
> > @@ -151,6 +154,15 @@ struct kvmi {
> >  	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
> >  	DECLARE_BITMAP(vm_ev_mask, KVMI_NUM_EVENTS);
> > =20
> > +#define SINGLE_STEP_MAX_DEPTH 8
> > +	struct {
> > +		gfn_t gfn;
> > +		u8 old_access;
> > +		u32 old_write_bitmap;
> > +	} ss_context[SINGLE_STEP_MAX_DEPTH];
> > +	u8 ss_level;
> > +	atomic_t ss_active;

