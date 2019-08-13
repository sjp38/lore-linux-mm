Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EFBC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 968152084D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:57:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 968152084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48D766B0006; Tue, 13 Aug 2019 07:57:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43E446B0007; Tue, 13 Aug 2019 07:57:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3536D6B0008; Tue, 13 Aug 2019 07:57:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 126816B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:57:31 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BA4A6440C
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:57:30 +0000 (UTC)
X-FDA: 75817254660.26.dog73_4180706ea4e11
X-HE-Tag: dog73_4180706ea4e11
X-Filterd-Recvd-Size: 10397
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:57:29 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 80BF030644BA;
	Tue, 13 Aug 2019 14:57:28 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 4AAC8305B7A0;
	Tue, 13 Aug 2019 14:57:28 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org, Paolo Bonzini
	<pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tamas K Lengyel
	<tamas@tklengyel.com>, Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Zhang@vger.kernel.org, Yu C
	<yu.c.zhang@intel.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
In-Reply-To: <20190812202030.GB1437@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-2-alazar@bitdefender.com>
	<20190812202030.GB1437@linux.intel.com>
Date: Tue, 13 Aug 2019 14:57:55 +0300
Message-ID: <1565697475.2eE1bB.4545.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 13:20:30 -0700, Sean Christopherson <sean.j.christoph=
erson@intel.com> wrote:
> On Fri, Aug 09, 2019 at 06:59:16PM +0300, Adalbert Laz=C4=83r wrote:
> > diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> > index 72fa955f4a15..f70a6a1b6814 100644
> > --- a/arch/x86/kvm/Kconfig
> > +++ b/arch/x86/kvm/Kconfig
> > @@ -96,6 +96,13 @@ config KVM_MMU_AUDIT
> >  	 This option adds a R/W kVM module parameter 'mmu_audit', which all=
ows
> >  	 auditing of KVM MMU events at runtime.
> > =20
> > +config KVM_INTROSPECTION
> > +	bool "VM Introspection"
> > +	depends on KVM && (KVM_INTEL || KVM_AMD)
> > +	help
> > +	 This option enables functions to control the execution of VM-s, qu=
ery
> > +	 the state of the vCPU-s (GPR-s, MSR-s etc.).
>=20
> This does a lot more than enable functions, it allows userspace to do a=
ll
> of these things *while the VM is running*.  Everything above can alread=
y
> be done by userspace.

First of all, thanks for helping us with this patch series.

Do you mean something like this?

	This option enables an introspection app to control any running
	VM if userspace/QEMU allows it.

>=20
> The "-s" syntax is difficult to read and unnecessary, e.g. at first I
> thought VM-s was referring to a new subsystem or feature introduced by
> introspection.  VMs, vCPUs, GPRs, MSRs, etc...
>=20
> > diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> > index c38cc5eb7e73..582b0187f5a4 100644
> > --- a/include/linux/kvm_host.h
> > +++ b/include/linux/kvm_host.h
> > @@ -455,6 +455,10 @@ struct kvm {
> >  	struct srcu_struct srcu;
> >  	struct srcu_struct irq_srcu;
> >  	pid_t userspace_pid;
> > +
> > +	struct completion kvmi_completed;
> > +	refcount_t kvmi_ref;
>=20
> The refcounting approach seems a bit backwards, and AFAICT is driven by
> implementing unhook via a message, which also seems backwards.  I assum=
e
> hook and unhook are relatively rare events and not performance critical=
,
> so make those the restricted/slow flows, e.g. force userspace to quiesc=
e
> the VM by making unhook() mutually exclusive with every vcpu ioctl() an=
d
> maybe anything that takes kvm->lock.=20
>=20
> Then kvmi_ioctl_unhook() can use thread_stop() and kvmi_recv() just nee=
ds
> to check kthread_should_stop().
>=20
> That way kvmi doesn't need to be refcounted since it's guaranteed to be
> alive if the pointer is non-null.  Eliminating the refcounting will cle=
an
> up a lot of the code by eliminating calls to kvmi_{get,put}(), e.g.
> wrappers like kvmi_breakpoint_event() just check vcpu->kvmi, or maybe
> even get dropped altogether.

The unhook event has been added to cover the following case: while the
introspection tool runs in another VM, both VMs, the virtual appliance
and the introspected VM, could be paused by the user. We needed a way
to signal this to the introspection tool and give it time to unhook
(the introspected VM has to run and execute the introspection commands
during this phase). The receiving threads quits when the socket is closed
(by QEMU or by the introspection tool).

It's a bit unclear how, but we'll try to get ride of the refcount object,
which will remove a lot of code, indeed.

>=20
> > +	void *kvmi;
>=20
> Why is this a void*?  Just forward declare struct kvmi in kvmi.h.
>=20
> IMO this should be 'struct kvm_introspection *introspection', similar t=
o
> 'struct kvm_vcpu_arch arch' and 'struct kvm_vmx'.  Ditto for the vCPU
> flavor.  Local variables could be kvmi+vcpui, kvm_i+vcpu_i, or maybe
> a more long form if someone can come up with a good abbreviation?
>=20
> Using 'ikvm' as the local variable name when everything else refers to
> introspection as 'kvmi' is especially funky.

We'll do.

>=20
> >  };
> > =20
> >  #define kvm_err(fmt, ...) \
> > diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
> > new file mode 100644
> > index 000000000000..e36de3f9f3de
> > --- /dev/null
> > +++ b/include/linux/kvmi.h
> > @@ -0,0 +1,23 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +#ifndef __KVMI_H__
> > +#define __KVMI_H__
> > +
> > +#define kvmi_is_present() IS_ENABLED(CONFIG_KVM_INTROSPECTION)
>=20
> Peeking forward a few patches, introspection should have a module param=
.

Like kvm.introspection=3Dtrue/False ?

> The code is also inconsistent in its usage of kvmi_is_present() versus
> #ifdef CONFIG_KVM_INTROSPECTION.
>=20
> And maybe kvm_is_instrospection_enabled() so that the gating function h=
as
> a more descriptive name for first-time readers?

Right.

> > diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
> > new file mode 100644
> > index 000000000000..dbf63ad0862f
> > --- /dev/null
> > +++ b/include/uapi/linux/kvmi.h
> > @@ -0,0 +1,68 @@
> > +/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
> > +#ifndef _UAPI__LINUX_KVMI_H
> > +#define _UAPI__LINUX_KVMI_H
> > +
> > +/*
> > + * KVMI structures and definitions
> > + */
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/types.h>
> > +
> > +#define KVMI_VERSION 0x00000001
> > +
> > +enum {
> > +	KVMI_EVENT_REPLY           =3D 0,
> > +	KVMI_EVENT                 =3D 1,
> > +
> > +	KVMI_FIRST_COMMAND         =3D 2,
> > +
> > +	KVMI_GET_VERSION           =3D 2,
> > +	KVMI_CHECK_COMMAND         =3D 3,
> > +	KVMI_CHECK_EVENT           =3D 4,
> > +	KVMI_GET_GUEST_INFO        =3D 5,
> > +	KVMI_GET_VCPU_INFO         =3D 6,
> > +	KVMI_PAUSE_VCPU            =3D 7,
> > +	KVMI_CONTROL_VM_EVENTS     =3D 8,
> > +	KVMI_CONTROL_EVENTS        =3D 9,
> > +	KVMI_CONTROL_CR            =3D 10,
> > +	KVMI_CONTROL_MSR           =3D 11,
> > +	KVMI_CONTROL_VE            =3D 12,
> > +	KVMI_GET_REGISTERS         =3D 13,
> > +	KVMI_SET_REGISTERS         =3D 14,
> > +	KVMI_GET_CPUID             =3D 15,
> > +	KVMI_GET_XSAVE             =3D 16,
> > +	KVMI_READ_PHYSICAL         =3D 17,
> > +	KVMI_WRITE_PHYSICAL        =3D 18,
> > +	KVMI_INJECT_EXCEPTION      =3D 19,
> > +	KVMI_GET_PAGE_ACCESS       =3D 20,
> > +	KVMI_SET_PAGE_ACCESS       =3D 21,
> > +	KVMI_GET_MAP_TOKEN         =3D 22,
> > +	KVMI_GET_MTRR_TYPE         =3D 23,
> > +	KVMI_CONTROL_SPP           =3D 24,
> > +	KVMI_GET_PAGE_WRITE_BITMAP =3D 25,
> > +	KVMI_SET_PAGE_WRITE_BITMAP =3D 26,
> > +	KVMI_CONTROL_CMD_RESPONSE  =3D 27,
>=20
> Each command should be introduced along with the patch that adds the
> associated functionality.
>=20
> It'd be helpful to incorporate the scope of the command in the name,
> e.g. VM vs. vCPU.
>=20
> Why are VM and vCPU commands smushed together?
>
> > +
> > +	KVMI_NEXT_AVAILABLE_COMMAND,
>=20
> Why not KVMI_NR_COMMANDS or KVM_NUM_COMMANDS?  At least be consistent
> between COMMANDS and EVENTS below.

This looks odd, indeed.  The intention was that the size of an internal
bitmap be KVMI_NEXT_AVAILABLE_COMMAND-KVMI_FIRST_COMMAND, but it was
too complicated. It is probably a leftover.

> > diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
> > new file mode 100644
> > index 000000000000..20638743bd03
> > --- /dev/null
> > +++ b/virt/kvm/kvmi.c
> > @@ -0,0 +1,64 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +/*
> > + * KVM introspection
> > + *
> > + * Copyright (C) 2017-2019 Bitdefender S.R.L.
> > + *
> > + */
> > +#include <uapi/linux/kvmi.h>
> > +#include "kvmi_int.h"
> > +
> > +int kvmi_init(void)
> > +{
> > +	return 0;
> > +}
> > +
> > +void kvmi_uninit(void)
> > +{
> > +}
> > +
> > +struct kvmi * __must_check kvmi_get(struct kvm *kvm)
> > +{
> > +	if (refcount_inc_not_zero(&kvm->kvmi_ref))
> > +		return kvm->kvmi;
> > +
> > +	return NULL;
> > +}
> > +
> > +static void kvmi_destroy(struct kvm *kvm)
> > +{
> > +}
> > +
> > +static void kvmi_release(struct kvm *kvm)
> > +{
> > +	kvmi_destroy(kvm);
> > +
> > +	complete(&kvm->kvmi_completed);
> > +}
> > +
> > +/* This function may be called from atomic context and must not slee=
p */
> > +void kvmi_put(struct kvm *kvm)
> > +{
> > +	if (refcount_dec_and_test(&kvm->kvmi_ref))
> > +		kvmi_release(kvm);
> > +}
> > +
> > +void kvmi_create_vm(struct kvm *kvm)
> > +{
> > +	init_completion(&kvm->kvmi_completed);
> > +	complete(&kvm->kvmi_completed);
>=20
> Pretty sure you don't want to be calling complete() here.

The intention was to stop the hooking ioctl until the VM is
created. A better name for 'kvmi_completed' would have been
'ready_to_be_introspected', as kvmi_hook() will wait for it.

We'll see how we can get ride of the completion object.

Thanks.

