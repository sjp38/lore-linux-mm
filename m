Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2339C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:25:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE6C920663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:25:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE6C920663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 502286B0005; Tue, 13 Aug 2019 11:25:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B0F06B0006; Tue, 13 Aug 2019 11:25:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C6FA6B0007; Tue, 13 Aug 2019 11:25:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 171C86B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:25:13 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B2C6D181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:25:12 +0000 (UTC)
X-FDA: 75817778064.24.knot09_84c117be63f51
X-HE-Tag: knot09_84c117be63f51
X-Filterd-Recvd-Size: 3490
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:25:12 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp01.buh.bitdefender.com [10.17.80.75])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 3B78B30644BA;
	Tue, 13 Aug 2019 18:25:10 +0300 (EEST)
Received: from localhost (unknown [195.210.4.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 228B8304BD70;
	Tue, 13 Aug 2019 18:25:10 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 16/92] kvm: introspection: handle events and event
 replies
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
In-Reply-To: <08325b3b-3af9-382b-7c0f-8410e8fcb545@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-17-alazar@bitdefender.com>
	<08325b3b-3af9-382b-7c0f-8410e8fcb545@redhat.com>
Date: Tue, 13 Aug 2019 18:25:36 +0300
Message-ID: <1565709936.aAF8B07.6681.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 10:55:21 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> >=20
> > +			 reply->padding2);
> > +
> > +	ivcpu->reply_waiting =3D false;
> > +	return expected->error;
> > +}
> > +
> >  /*
>=20
> Is this missing a wakeup?
>=20
> > =20
> > +static bool need_to_wait(struct kvm_vcpu *vcpu)
> > +{
> > +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> > +
> > +	return ivcpu->reply_waiting;
> > +}
> > +
>=20
> Do you actually need this function?  It seems to me that everywhere you
> call it you already have an ivcpu, so you can just access the field.
>=20
> Also, "reply_waiting" means "there is a reply that is waiting".  What
> you mean is "waiting_for_reply".

In an older version, handle_event_reply() was executed from the receiving
thread (having another name) and it contained a wakeup function. Now,
indeed, 'waiting_for_reply' is the right name.
=20
> The overall structure of the jobs code is confusing.  The same function
> kvm_run_jobs_and_wait is an infinite loop before and gets a "break"
> later.  It is also not clear why kvmi_job_wait is called through a job.
>  Can you have instead just kvm_run_jobs in KVM_REQ_INTROSPECTION, and
> something like this instead when sending an event:
>=20
> int kvmi_wait_for_reply(struct kvm_vcpu *vcpu)
> {
> 	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
>=20
> 	while (ivcpu->waiting_for_reply) {
> 		kvmi_run_jobs(vcpu);
>=20
> 		err =3D swait_event_killable(*wq,
> 				!ivcpu->waiting_for_reply ||
> 				!list_empty(&ivcpu->job_list));
>=20
> 		if (err)
> 			return -EINTR;
> 	}
>=20
> 	return 0;
> }
>=20
> ?
>=20
> Paolo

Much better :) Thank you.


