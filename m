Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CA3CC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:24:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64C9820844
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:24:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64C9820844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15DCE6B0003; Tue, 13 Aug 2019 10:24:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10EEC6B0006; Tue, 13 Aug 2019 10:24:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3EF96B0007; Tue, 13 Aug 2019 10:24:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0193.hostedemail.com [216.40.44.193])
	by kanga.kvack.org (Postfix) with ESMTP id CD7CA6B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:24:19 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 74F89185D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:24:19 +0000 (UTC)
X-FDA: 75817624638.06.floor66_25b1efbd8291d
X-HE-Tag: floor66_25b1efbd8291d
X-Filterd-Recvd-Size: 3388
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:24:18 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 2E11830644BA;
	Tue, 13 Aug 2019 17:24:17 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 11E7F303EF04;
	Tue, 13 Aug 2019 17:24:17 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 02/92] kvm: introspection: add basic ioctls
 (hook/unhook)
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
In-Reply-To: <58808ef0-57b1-47ac-a115-e1dd64a15b0a@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-3-alazar@bitdefender.com>
	<58808ef0-57b1-47ac-a115-e1dd64a15b0a@redhat.com>
Date: Tue, 13 Aug 2019 17:24:43 +0300
Message-ID: <1565706283.3Aa8b.27165.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We'll do.

On Tue, 13 Aug 2019 10:44:28 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> > +static int kvmi_recv(void *arg)
> > +{
> > +	struct kvmi *ikvm =3D arg;
> > +
> > +	kvmi_info(ikvm, "Hooking VM\n");
> > +
> > +	while (kvmi_msg_process(ikvm))
> > +		;
> > +
> > +	kvmi_info(ikvm, "Unhooking VM\n");
> > +
> > +	kvmi_end_introspection(ikvm);
> > +
> > +	return 0;
> > +}
> > +
>=20
> Rename this to kvmi_recv_thread instead, please.
>=20
> > +
> > +	/*
> > +	 * Make sure all the KVM/KVMI structures are linked and no pointer
> > +	 * is read as NULL after the reference count has been set.
> > +	 */
> > +	smp_mb__before_atomic();
>=20
> This is an smp_wmb(), not an smp_mb__before_atomic().  Add a comment
> that it pairs with the refcount_inc_not_zero in kvmi_get.
>=20
> > +	refcount_set(&kvm->kvmi_ref, 1);
> > +
>=20
>=20
> > @@ -57,8 +183,27 @@ void kvmi_destroy_vm(struct kvm *kvm)
> >  	if (!ikvm)
> >  		return;
> > =20
> > +	/* trigger socket shutdown - kvmi_recv() will start shutdown proces=
s */
> > +	kvmi_sock_shutdown(ikvm);
> > +
> >  	kvmi_put(kvm);
> > =20
> >  	/* wait for introspection resources to be released */
> >  	wait_for_completion_killable(&kvm->kvmi_completed);
> >  }
> > +
>=20
> This addition means that kvmi_destroy_vm should have called
> kvmi_end_introspection instead.  In patch 1, kvmi_end_introspection
> should have been just kvmi_put, now this patch can add kvmi_sock_shutdo=
wn.
>=20
> Paolo

