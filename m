Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B87C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:08:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C243320679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C243320679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5514C6B0005; Tue, 13 Aug 2019 13:08:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DAC46B0006; Tue, 13 Aug 2019 13:08:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EEF06B0007; Tue, 13 Aug 2019 13:08:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id 17BD26B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:08:03 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A6AB2181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:08:02 +0000 (UTC)
X-FDA: 75818037204.20.owner47_bf6b2f37b11e
X-HE-Tag: owner47_bf6b2f37b11e
X-Filterd-Recvd-Size: 3721
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:08:02 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp01.buh.bitdefender.com [10.17.80.75])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 5DE5F3011FC2;
	Tue, 13 Aug 2019 20:08:00 +0300 (EEST)
Received: from localhost (unknown [195.210.4.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 47A5F304BD70;
	Tue, 13 Aug 2019 20:08:00 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 06/92] kvm: introspection: add
 KVMI_CONTROL_CMD_RESPONSE
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
In-Reply-To: <e8f59b08-734a-2ce1-ae28-3cc9d90c0bcb@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-7-alazar@bitdefender.com>
	<e8f59b08-734a-2ce1-ae28-3cc9d90c0bcb@redhat.com>
Date: Tue, 13 Aug 2019 20:08:27 +0300
Message-ID: <1565716107.4DfaBE.19731.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 11:15:34 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> > +If `now` is 1, the command reply is enabled/disabled (according to
> > +`enable`) starting with the current command. For example, `enable=3D=
0`
> > +and `now=3D1` means that the reply is disabled for this command too,
> > +while `enable=3D0` and `now=3D0` means that a reply will be send for=
 this
> > +command, but not for the next ones (until enabled back with another
> > +*KVMI_CONTROL_CMD_RESPONSE*).
> > +
> > +This command is used by the introspection tool to disable the replie=
s
> > +for commands returning an error code only (eg. *KVMI_SET_REGISTERS*)
> > +when an error is less likely to happen. For example, the following
> > +commands can be used to reply to an event with a single `write()` ca=
ll:
> > +
> > +	KVMI_CONTROL_CMD_RESPONSE enable=3D0 now=3D1
> > +	KVMI_SET_REGISTERS vcpu=3DN
> > +	KVMI_EVENT_REPLY   vcpu=3DN
> > +	KVMI_CONTROL_CMD_RESPONSE enable=3D1 now=3D0
>=20
> I don't understand the usage.  Is there any case where you want now =3D=
=3D 1
> actually?  Can you just say that KVMI_CONTROL_CMD_RESPONSE never has a
> reply, or to make now=3D=3Denable?

The enable=3D1 now=3D1 is for pause VM:

	KVMI_CONTROL_CMD_RESPONSE enable=3D0 now=3D1
	KVMI_PAUSE_VCPU 0
	KVMI_PAUSE_VCPU 1
	...
	KVMI_CONTROL_CMD_RESPONSE enable=3D1 now=3D1

We wait for a reply to make sure the vCPUs were stopped without waiting
for their pause events.

We can get around from userspace, if you like:

	KVMI_CONTROL_CMD_RESPONSE enable=3D0 now=3D1
	KVMI_PAUSE_VCPU 0
	KVMI_PAUSE_VCPU 1
	...
	KVMI_PAUSE_VCPU N-2
	KVMI_CONTROL_CMD_RESPONSE enable=3D1 now=3D0
	KVMI_PAUSE_VCPU N-1

>=20
> > +	if (err)
> > +		kvmi_warn(ikvm, "Error code %d discarded for message id %d\n",
> > +			  err, msg->id);
> > +
>=20
> Would it make sense to even close the socket if there is an error?
>=20
> Paolo

Sure.

