Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D42BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:47:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59AC120578
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:47:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AC120578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B2836B0005; Wed, 14 Aug 2019 05:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2626D6B0006; Wed, 14 Aug 2019 05:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 152976B0007; Wed, 14 Aug 2019 05:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id E83546B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:47:57 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 98063180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:47:57 +0000 (UTC)
X-FDA: 75820556994.28.work58_b39f9f674625
X-HE-Tag: work58_b39f9f674625
X-Filterd-Recvd-Size: 4254
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:47:56 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E3D683016E60;
	Wed, 14 Aug 2019 12:47:55 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id CF30D305B7A0;
	Wed, 14 Aug 2019 12:47:55 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: Sean Christopherson <sean.j.christopherson@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org, Radim =?iso-8859-2?b?S3LobeH4?=
	<rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>, Mathieu Tarral
	<mathieu.tarral@protonmail.com>, Samuel =?iso-8859-1?q?Laur=E9n?=
	<samuel.lauren@iki.fi>, Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka
	<jan.kiszka@siemens.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org, Yu C
	<yu.c.zhang@intel.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
In-Reply-To: <20190813150128.GB13991@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-2-alazar@bitdefender.com>
	<20190812202030.GB1437@linux.intel.com>
	<5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
	<5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
	<20190813150128.GB13991@linux.intel.com>
Date: Wed, 14 Aug 2019 12:48:22 +0300
Message-ID: <1565776102.75165.5381.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 08:01:28 -0700, Sean Christopherson <sean.j.christoph=
erson@intel.com> wrote:
> On Tue, Aug 13, 2019 at 02:09:51PM +0200, Paolo Bonzini wrote:
> > On 13/08/19 13:57, Adalbert Laz=C4=83r wrote:
> > >> The refcounting approach seems a bit backwards, and AFAICT is driv=
en by
> > >> implementing unhook via a message, which also seems backwards.  I =
assume
> > >> hook and unhook are relatively rare events and not performance cri=
tical,
> > >> so make those the restricted/slow flows, e.g. force userspace to q=
uiesce
> > >> the VM by making unhook() mutually exclusive with every vcpu ioctl=
() and
> > >> maybe anything that takes kvm->lock.=20
> > >>
> > >> Then kvmi_ioctl_unhook() can use thread_stop() and kvmi_recv() jus=
t needs
> > >> to check kthread_should_stop().
> > >>
> > >> That way kvmi doesn't need to be refcounted since it's guaranteed =
to be
> > >> alive if the pointer is non-null.  Eliminating the refcounting wil=
l clean
> > >> up a lot of the code by eliminating calls to kvmi_{get,put}(), e.g=
.
> > >> wrappers like kvmi_breakpoint_event() just check vcpu->kvmi, or ma=
ybe
> > >> even get dropped altogether.
> > >=20
> > > The unhook event has been added to cover the following case: while =
the
> > > introspection tool runs in another VM, both VMs, the virtual applia=
nce
> > > and the introspected VM, could be paused by the user. We needed a w=
ay
> > > to signal this to the introspection tool and give it time to unhook
> > > (the introspected VM has to run and execute the introspection comma=
nds
> > > during this phase). The receiving threads quits when the socket is =
closed
> > > (by QEMU or by the introspection tool).
>=20
> Why does closing the socket require destroying the kvmi object?  E.g. c=
an
> it be marked as defunct or whatever and only fully removed on a synchro=
nous
> unhook from userspace?  Re-hooking could either require said unhook, or
> maybe reuse the existing kvmi object with a new socket.

Will it be better to have the following ioctls?

  - hook (alloc kvmi and kvmi_vcpu structs)
  - notify_imminent_unhook (send the KVMI_EVENT_UNHOOK event)
  - unhook (free kvmi and kvmi_vcpu structs)

