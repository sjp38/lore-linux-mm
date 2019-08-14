Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 108D8C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B957120578
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 09:39:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B957120578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3BB6B0005; Wed, 14 Aug 2019 05:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 464C56B0006; Wed, 14 Aug 2019 05:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37B716B0007; Wed, 14 Aug 2019 05:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id 181EC6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 05:39:07 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AC76B8248AA2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:39:06 +0000 (UTC)
X-FDA: 75820534692.16.dogs59_4f7ec34b7a131
X-HE-Tag: dogs59_4f7ec34b7a131
X-Filterd-Recvd-Size: 2999
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:39:06 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 46468305FFAD;
	Wed, 14 Aug 2019 12:39:04 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 2FAD9303EF05;
	Wed, 14 Aug 2019 12:39:04 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 14/92] kvm: introspection: handle introspection
 commands before returning to guest
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
In-Reply-To: <97cdf9cb-286c-2387-6cb5-003b30f74c7e@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-15-alazar@bitdefender.com>
	<645d86f5-67f6-f5d3-3fbb-5ee9898a7ef8@redhat.com>
	<5d52c10e.1c69fb81.26904.fd34SMTPIN_ADDED_BROKEN@mx.google.com>
	<97cdf9cb-286c-2387-6cb5-003b30f74c7e@redhat.com>
Date: Wed, 14 Aug 2019 12:39:31 +0300
Message-ID: <1565775571.4fFd4.4026.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000026, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 16:45:11 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 13/08/19 15:54, Adalbert Laz=C4=83r wrote:
> >     Leaving kvm_vcpu_block() in order to handle a request such as 'pa=
use',
> >     would cause the vCPU to enter the guest when resumed. Most of the
> >     time this does not appear to be an issue, but during early boot i=
t
> >     can happen for a non-boot vCPU to start executing code from areas=
 that
> >     first needed to be set up by vCPU #0.
> >    =20
> >     In a particular case, vCPU #1 executed code which resided in an a=
rea
> >     not covered by a memslot, which caused an EPT violation that got
> >     turned in mmu_set_spte() into a MMIO request that required emulat=
ion.
> >     Unfortunatelly, the emulator tripped, exited to userspace and the=
 VM
> >     was aborted.
>=20
> Okay, this makes sense.  Maybe you want to handle KVM_REQ_INTROSPECTION
> in vcpu_run rather than vcpu_enter_guest?
>=20
> Paolo

Right! We've missed that.

