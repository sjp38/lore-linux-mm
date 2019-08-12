Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CEAEC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACFC820684
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACFC820684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473ED6B0008; Mon, 12 Aug 2019 16:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424716B000A; Mon, 12 Aug 2019 16:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 312CA6B000C; Mon, 12 Aug 2019 16:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id 04D6A6B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:51:14 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 808118248AA1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:51:14 +0000 (UTC)
X-FDA: 75814970868.10.guide52_a9c8de12c813
X-HE-Tag: guide52_a9c8de12c813
X-Filterd-Recvd-Size: 20046
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:51:12 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 13:50:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="183678501"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by FMSMGA003.fm.intel.com with ESMTP; 12 Aug 2019 13:50:39 -0700
Date: Mon, 12 Aug 2019 13:50:39 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@linux.intel.com,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	=?utf-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>,
	Jim Mattson <jmattson@google.com>, Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH v6 64/92] kvm: introspection: add single-stepping
Message-ID: <20190812205038.GC1437@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-65-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190809160047.8319-65-alazar@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 07:00:19PM +0300, Adalbert Laz=C4=83r wrote:
> From: Nicu=C8=99or C=C3=AE=C8=9Bu <ncitu@bitdefender.com>
>=20
> This would be used either if the introspection tool request it as a
> reply to a KVMI_EVENT_PF event or to cope with instructions that cannot
> be handled by the x86 emulator during the handling of a VMEXIT. In
> these situations, all other vCPU-s are kicked and held, the EPT-based
> protection is removed and the guest is single stepped by the vCPU that
> triggered the initial VMEXIT. Upon completion the EPT-base protection
> is reinstalled and all vCPU-s all allowed to return to the guest.
>=20
> This is a rather slow workaround that kicks in occasionally. In the
> future, the most frequently single-stepped instructions should be added
> to the emulator (usually, stores to and from memory - SSE/AVX).
>=20
> For the moment it works only on Intel.
>=20
> CC: Jim Mattson <jmattson@google.com>
> CC: Sean Christopherson <sean.j.christopherson@intel.com>
> CC: Joerg Roedel <joro@8bytes.org>
> Signed-off-by: Nicu=C8=99or C=C3=AE=C8=9Bu <ncitu@bitdefender.com>
> Co-developed-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> Signed-off-by: Mihai Don=C8=9Bu <mdontu@bitdefender.com>
> Co-developed-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  arch/x86/include/asm/kvm_host.h |   3 +
>  arch/x86/kvm/kvmi.c             |  47 ++++++++++-
>  arch/x86/kvm/svm.c              |   5 ++
>  arch/x86/kvm/vmx/vmx.c          |  17 ++++
>  arch/x86/kvm/x86.c              |  19 +++++
>  include/linux/kvmi.h            |   4 +
>  virt/kvm/kvmi.c                 | 145 +++++++++++++++++++++++++++++++-
>  virt/kvm/kvmi_int.h             |  16 ++++
>  8 files changed, 253 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm=
_host.h
> index ad36a5fc2048..60e2c298d469 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -1016,6 +1016,7 @@ struct kvm_x86_ops {
>  	void (*msr_intercept)(struct kvm_vcpu *vcpu, unsigned int msr,
>  				bool enable);
>  	bool (*desc_intercept)(struct kvm_vcpu *vcpu, bool enable);
> +	void (*set_mtf)(struct kvm_vcpu *vcpu, bool enable);

MTF is a VMX specific implementation of single-stepping, this should be
enable_single_step() or something along those lines.  For example, I assu=
me
SVM could implement something that is mostly functional via RFLAGS.TF.

>  	void (*cr3_write_exiting)(struct kvm_vcpu *vcpu, bool enable);
>  	bool (*nested_pagefault)(struct kvm_vcpu *vcpu);
>  	bool (*spt_fault)(struct kvm_vcpu *vcpu);
> @@ -1628,6 +1629,8 @@ void kvm_arch_msr_intercept(struct kvm_vcpu *vcpu=
, unsigned int msr,
>  				bool enable);
>  bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu);
>  bool kvm_spt_fault(struct kvm_vcpu *vcpu);
> +void kvm_set_mtf(struct kvm_vcpu *vcpu, bool enable);
> +void kvm_set_interrupt_shadow(struct kvm_vcpu *vcpu, int mask);
>  void kvm_control_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable)=
;
> =20
>  #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
> index 04cac5b8a4d0..f0ab4bd9eb37 100644
> --- a/arch/x86/kvm/kvmi.c
> +++ b/arch/x86/kvm/kvmi.c
> @@ -520,7 +520,6 @@ bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_=
t gpa, gva_t gva,
>  	u32 ctx_size;
>  	u64 ctx_addr;
>  	u32 action;
> -	bool singlestep_ignored;
>  	bool ret =3D false;
> =20
>  	if (!kvm_spt_fault(vcpu))
> @@ -533,7 +532,7 @@ bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_=
t gpa, gva_t gva,
>  	if (ivcpu->effective_rep_complete)
>  		return true;
> =20
> -	action =3D kvmi_msg_send_pf(vcpu, gpa, gva, access, &singlestep_ignor=
ed,
> +	action =3D kvmi_msg_send_pf(vcpu, gpa, gva, access, &ivcpu->ss_reques=
ted,
>  				  &ivcpu->rep_complete, &ctx_addr,
>  				  ivcpu->ctx_data, &ctx_size);
> =20
> @@ -547,6 +546,8 @@ bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_=
t gpa, gva_t gva,
>  		ret =3D true;
>  		break;
>  	case KVMI_EVENT_ACTION_RETRY:
> +		if (ivcpu->ss_requested && !kvmi_start_ss(vcpu, gpa, access))
> +			ret =3D true;
>  		break;
>  	default:
>  		kvmi_handle_common_event_actions(vcpu, action, "PF");
> @@ -758,6 +759,48 @@ int kvmi_arch_cmd_control_cr(struct kvm_vcpu *vcpu=
,
>  	return 0;
>  }
> =20
> +void kvmi_arch_start_single_step(struct kvm_vcpu *vcpu)
> +{
> +	kvm_set_mtf(vcpu, true);
> +
> +	/*
> +	 * Set block by STI only if the RFLAGS.IF =3D 1.
> +	 * Blocking by both STI and MOV/POP SS is not possible.
> +	 */
> +	if (kvm_arch_interrupt_allowed(vcpu))
> +		kvm_set_interrupt_shadow(vcpu, KVM_X86_SHADOW_INT_STI);

This is wrong, the STI shadow only exists if interrupts were unblocked
prior to STI.  I'm guessing this is a hack to workaround
kvmi_arch_stop_single_step() not properly handling the clearing case.

> +
> +}
> +
> +void kvmi_arch_stop_single_step(struct kvm_vcpu *vcpu)
> +{
> +	kvm_set_mtf(vcpu, false);
> +	/*
> +	 * The blocking by STI is cleared after the guest
> +	 * executes one instruction or incurs an exception.
> +	 * However we migh stop the SS before entering to guest,
> +	 * so be sure we are clearing the STI blocking.
> +	 */
> +	kvm_set_interrupt_shadow(vcpu, 0);

There are only three callers of kvmi_stop_ss(), it should be possible
to accurately update interruptibility:

  - kvmi_run_ss() fail, do nothing
  - VM-Exit that wasn't a single-step - clear interruptibility if the
    guest executed an instruction (including faulted on an instr).
  - MTF VM-Exit - do nothing (VMCS should already be up-to-date).

> +}
> +
> +u8 kvmi_arch_relax_page_access(u8 old, u8 new)
> +{
> +	u8 ret =3D old | new;
> +
> +	/*
> +	 * An SPTE entry with just the -wx bits set can trigger a
> +	 * misconfiguration error from the hardware, as it's the case
> +	 * for x86 where this access mode is used to mark I/O memory.
> +	 * Thus, we make sure that -wx accesses are translated to rwx.
> +	 */
> +	if ((ret & (KVMI_PAGE_ACCESS_W | KVMI_PAGE_ACCESS_X)) =3D=3D
> +	    (KVMI_PAGE_ACCESS_W | KVMI_PAGE_ACCESS_X))
> +		ret |=3D KVMI_PAGE_ACCESS_R;
> +
> +	return ret;
> +}
> +
>  static const struct {
>  	unsigned int allow_bit;
>  	enum kvm_page_track_mode track_mode;
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index b178b8900660..3481c0247680 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -7183,6 +7183,10 @@ static bool svm_spt_fault(struct kvm_vcpu *vcpu)
>  	return (svm->vmcb->control.exit_code =3D=3D SVM_EXIT_NPF);
>  }
> =20
> +static void svm_set_mtf(struct kvm_vcpu *vcpu, bool enable)
> +{
> +}
> +
>  static void svm_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable)
>  {
>  }
> @@ -7225,6 +7229,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_=
init =3D {
>  	.cpu_has_accelerated_tpr =3D svm_cpu_has_accelerated_tpr,
>  	.has_emulated_msr =3D svm_has_emulated_msr,
> =20
> +	.set_mtf =3D svm_set_mtf,
>  	.cr3_write_exiting =3D svm_cr3_write_exiting,
>  	.msr_intercept =3D svm_msr_intercept,
>  	.desc_intercept =3D svm_desc_intercept,
> diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
> index 7d1e341b51ad..f0369d0574dc 100644
> --- a/arch/x86/kvm/vmx/vmx.c
> +++ b/arch/x86/kvm/vmx/vmx.c
> @@ -5384,6 +5384,7 @@ static int handle_invalid_op(struct kvm_vcpu *vcp=
u)
> =20
>  static int handle_monitor_trap(struct kvm_vcpu *vcpu)
>  {
> +	kvmi_stop_ss(vcpu);
>  	return 1;
>  }
> =20
> @@ -5992,6 +5993,11 @@ static int vmx_handle_exit(struct kvm_vcpu *vcpu=
)
>  		}
>  	}
> =20
> +	if (kvmi_vcpu_enabled_ss(vcpu)
> +			&& exit_reason !=3D EXIT_REASON_EPT_VIOLATION
> +			&& exit_reason !=3D EXIT_REASON_MONITOR_TRAP_FLAG)

Bad indentation.  This is prevelant through the series.

> +		kvmi_stop_ss(vcpu);
> +
>  	if (exit_reason < kvm_vmx_max_exit_handlers
>  	    && kvm_vmx_exit_handlers[exit_reason])
>  		return kvm_vmx_exit_handlers[exit_reason](vcpu);
> @@ -7842,6 +7848,16 @@ static __exit void hardware_unsetup(void)
>  	free_kvm_area();
>  }
> =20
> +static void vmx_set_mtf(struct kvm_vcpu *vcpu, bool enable)
> +{
> +	if (enable)
> +		vmcs_set_bits(CPU_BASED_VM_EXEC_CONTROL,
> +			      CPU_BASED_MONITOR_TRAP_FLAG);
> +	else
> +		vmcs_clear_bits(CPU_BASED_VM_EXEC_CONTROL,
> +				CPU_BASED_MONITOR_TRAP_FLAG);
> +}
> +
>  static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
>  			      bool enable)
>  {
> @@ -7927,6 +7943,7 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_=
init =3D {
>  	.cpu_has_accelerated_tpr =3D report_flexpriority,
>  	.has_emulated_msr =3D vmx_has_emulated_msr,
> =20
> +	.set_mtf =3D vmx_set_mtf,
>  	.msr_intercept =3D vmx_msr_intercept,
>  	.cr3_write_exiting =3D vmx_cr3_write_exiting,
>  	.desc_intercept =3D vmx_desc_intercept,
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 38aaddadb93a..65855340249a 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -7358,6 +7358,13 @@ static int inject_pending_event(struct kvm_vcpu =
*vcpu, bool req_int_win)
>  {
>  	int r;
> =20
> +	if (kvmi_vcpu_enabled_ss(vcpu))
> +		/*
> +		 * We cannot inject events during single-stepping.
> +		 * Try again later.
> +		 */
> +		return -1;
> +
>  	/* try to reinject previous events if any */
> =20
>  	if (vcpu->arch.exception.injected)
> @@ -10134,6 +10141,18 @@ void kvm_control_cr3_write_exiting(struct kvm_=
vcpu *vcpu, bool enable)
>  }
>  EXPORT_SYMBOL(kvm_control_cr3_write_exiting);
> =20
> +void kvm_set_mtf(struct kvm_vcpu *vcpu, bool enable)
> +{
> +	kvm_x86_ops->set_mtf(vcpu, enable);
> +}
> +EXPORT_SYMBOL(kvm_set_mtf);
> +
> +void kvm_set_interrupt_shadow(struct kvm_vcpu *vcpu, int mask)
> +{
> +	kvm_x86_ops->set_interrupt_shadow(vcpu, mask);
> +}
> +EXPORT_SYMBOL(kvm_set_interrupt_shadow);

Why do these wrappers exist, and why are they exported?  Introspection is
built into kvm, any reason not to use kvm_x86_ops directly?  The most
definitely don't need to be exported.

> +
>  bool kvm_spt_fault(struct kvm_vcpu *vcpu)
>  {
>  	return kvm_x86_ops->spt_fault(vcpu);
> diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
> index 5d162b9e67f2..1dc90284dc3a 100644
> --- a/include/linux/kvmi.h
> +++ b/include/linux/kvmi.h
> @@ -22,6 +22,8 @@ bool kvmi_queue_exception(struct kvm_vcpu *vcpu);
>  void kvmi_trap_event(struct kvm_vcpu *vcpu);
>  bool kvmi_descriptor_event(struct kvm_vcpu *vcpu, u8 descriptor, u8 wr=
ite);
>  void kvmi_handle_requests(struct kvm_vcpu *vcpu);
> +void kvmi_stop_ss(struct kvm_vcpu *vcpu);
> +bool kvmi_vcpu_enabled_ss(struct kvm_vcpu *vcpu);

Spell out single step, and be consistent between single_step and singlest=
ep.
That applies to pretty much every variable and function unless doing so
really makes the verbosity obnoxious.

>  void kvmi_init_emulate(struct kvm_vcpu *vcpu);
>  void kvmi_activate_rep_complete(struct kvm_vcpu *vcpu);
>  bool kvmi_bp_intercepted(struct kvm_vcpu *vcpu, u32 dbg);
> @@ -44,6 +46,8 @@ static inline void kvmi_handle_requests(struct kvm_vc=
pu *vcpu) { }
>  static inline bool kvmi_hypercall_event(struct kvm_vcpu *vcpu) { retur=
n false; }
>  static inline bool kvmi_queue_exception(struct kvm_vcpu *vcpu) { retur=
n true; }
>  static inline void kvmi_trap_event(struct kvm_vcpu *vcpu) { }
> +static inline void kvmi_stop_ss(struct kvm_vcpu *vcpu) { }
> +static inline bool kvmi_vcpu_enabled_ss(struct kvm_vcpu *vcpu) { retur=
n false; }
>  static inline void kvmi_init_emulate(struct kvm_vcpu *vcpu) { }
>  static inline void kvmi_activate_rep_complete(struct kvm_vcpu *vcpu) {=
 }
>  static inline bool kvmi_bp_intercepted(struct kvm_vcpu *vcpu, u32 dbg)
> diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
> index d47a725a4045..a3a5af9080a9 100644
> --- a/virt/kvm/kvmi.c
> +++ b/virt/kvm/kvmi.c
> @@ -1260,11 +1260,19 @@ void kvmi_run_jobs(struct kvm_vcpu *vcpu)
>  	}
>  }
> =20
> +static bool need_to_wait_for_ss(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> +	struct kvmi *ikvm =3D IKVM(vcpu->kvm);
> +
> +	return atomic_read(&ikvm->ss_active) && !ivcpu->ss_owner;
> +}
> +
>  static bool need_to_wait(struct kvm_vcpu *vcpu)
>  {
>  	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> =20
> -	return ivcpu->reply_waiting;
> +	return ivcpu->reply_waiting || need_to_wait_for_ss(vcpu);
>  }
> =20
>  static bool done_waiting(struct kvm_vcpu *vcpu)
> @@ -1572,6 +1580,141 @@ int kvmi_cmd_pause_vcpu(struct kvm_vcpu *vcpu, =
bool wait)
>  	return 0;
>  }
> =20
> +void kvmi_stop_ss(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> +	struct kvm *kvm =3D vcpu->kvm;
> +	struct kvmi *ikvm;
> +	int i;
> +
> +	ikvm =3D kvmi_get(kvm);
> +	if (!ikvm)
> +		return;
> +
> +	if (unlikely(!ivcpu->ss_owner)) {
> +		kvmi_warn(ikvm, "%s\n", __func__);
> +		goto out;
> +	}
> +
> +	for (i =3D ikvm->ss_level; i--;)
> +		kvmi_set_gfn_access(kvm,
> +				    ikvm->ss_context[i].gfn,
> +				    ikvm->ss_context[i].old_access,
> +				    ikvm->ss_context[i].old_write_bitmap);
> +
> +	ikvm->ss_level =3D 0;
> +
> +	kvmi_arch_stop_single_step(vcpu);
> +
> +	atomic_set(&ikvm->ss_active, false);
> +	/*
> +	 * Make ss_active update visible
> +	 * before resuming all the other vCPUs.
> +	 */
> +	smp_mb__after_atomic();
> +	kvm_make_all_cpus_request(kvm, 0);
> +
> +	ivcpu->ss_owner =3D false;
> +
> +out:
> +	kvmi_put(kvm);
> +}
> +EXPORT_SYMBOL(kvmi_stop_ss);
> +
> +static bool kvmi_acquire_ss(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> +	struct kvmi *ikvm =3D IKVM(vcpu->kvm);
> +
> +	if (ivcpu->ss_owner)
> +		return true;
> +
> +	if (atomic_cmpxchg(&ikvm->ss_active, false, true) !=3D false)
> +		return false;
> +
> +	kvm_make_all_cpus_request(vcpu->kvm, KVM_REQ_INTROSPECTION |
> +						KVM_REQUEST_WAIT);
> +
> +	ivcpu->ss_owner =3D true;
> +
> +	return true;
> +}
> +
> +static bool kvmi_run_ss(struct kvm_vcpu *vcpu, gpa_t gpa, u8 access)
> +{
> +	struct kvmi *ikvm =3D IKVM(vcpu->kvm);
> +	u8 old_access, new_access;
> +	u32 old_write_bitmap;
> +	gfn_t gfn =3D gpa_to_gfn(gpa);
> +	int err;
> +
> +	kvmi_arch_start_single_step(vcpu);
> +
> +	err =3D kvmi_get_gfn_access(ikvm, gfn, &old_access, &old_write_bitmap=
);
> +	/* likely was removed from radix tree due to rwx */
> +	if (err) {
> +		kvmi_warn(ikvm, "%s: gfn 0x%llx not found in the radix tree\n",
> +			  __func__, gfn);
> +		return true;
> +	}
> +
> +	if (ikvm->ss_level =3D=3D SINGLE_STEP_MAX_DEPTH - 1) {
> +		kvmi_err(ikvm, "single step limit reached\n");
> +		return false;
> +	}
> +
> +	ikvm->ss_context[ikvm->ss_level].gfn =3D gfn;
> +	ikvm->ss_context[ikvm->ss_level].old_access =3D old_access;
> +	ikvm->ss_context[ikvm->ss_level].old_write_bitmap =3D old_write_bitma=
p;
> +	ikvm->ss_level++;
> +
> +	new_access =3D kvmi_arch_relax_page_access(old_access, access);
> +
> +	kvmi_set_gfn_access(vcpu->kvm, gfn, new_access, old_write_bitmap);
> +
> +	return true;
> +}
> +
> +bool kvmi_start_ss(struct kvm_vcpu *vcpu, gpa_t gpa, u8 access)
> +{
> +	bool ret =3D false;
> +
> +	while (!kvmi_acquire_ss(vcpu)) {
> +		int err =3D kvmi_run_jobs_and_wait(vcpu);
> +
> +		if (err) {
> +			kvmi_err(IKVM(vcpu->kvm), "kvmi_acquire_ss() has failed\n");
> +			goto out;
> +		}
> +	}
> +
> +	if (kvmi_run_ss(vcpu, gpa, access))
> +		ret =3D true;
> +	else
> +		kvmi_stop_ss(vcpu);
> +
> +out:
> +	return ret;
> +}
> +
> +bool kvmi_vcpu_enabled_ss(struct kvm_vcpu *vcpu)
> +{
> +	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> +	struct kvmi *ikvm;
> +	bool ret;
> +
> +	ikvm =3D kvmi_get(vcpu->kvm);
> +	if (!ikvm)
> +		return false;
> +
> +	ret =3D ivcpu->ss_owner;
> +
> +	kvmi_put(vcpu->kvm);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(kvmi_vcpu_enabled_ss);
> +
>  static void kvmi_job_abort(struct kvm_vcpu *vcpu, void *ctx)
>  {
>  	struct kvmi_vcpu *ivcpu =3D IVCPU(vcpu);
> diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
> index d7f9858d3e97..1550fe33ed48 100644
> --- a/virt/kvm/kvmi_int.h
> +++ b/virt/kvm/kvmi_int.h
> @@ -126,6 +126,9 @@ struct kvmi_vcpu {
>  		DECLARE_BITMAP(high, KVMI_NUM_MSR);
>  	} msr_mask;
> =20
> +	bool ss_owner;

Why is single-stepping mutually exclusive across all vCPUs?  Does that
always have to be the case?

> +	bool ss_requested;
> +
>  	struct list_head job_list;
>  	spinlock_t job_lock;
> =20
> @@ -151,6 +154,15 @@ struct kvmi {
>  	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
>  	DECLARE_BITMAP(vm_ev_mask, KVMI_NUM_EVENTS);
> =20
> +#define SINGLE_STEP_MAX_DEPTH 8
> +	struct {
> +		gfn_t gfn;
> +		u8 old_access;
> +		u32 old_write_bitmap;
> +	} ss_context[SINGLE_STEP_MAX_DEPTH];
> +	u8 ss_level;
> +	atomic_t ss_active;

Good opportunity for an unnamed struct, e.g.

	struct {
		struct single_step_context[...];
		bool owner;
		bool requested;
		u8 level
		atomic_t active;
	} single_step;

> +
>  	struct {
>  		bool initialized;
>  		atomic_t enabled;
> @@ -224,6 +236,7 @@ int kvmi_add_job(struct kvm_vcpu *vcpu,
>  		 void *ctx, void (*free_fct)(void *ctx));
>  void kvmi_handle_common_event_actions(struct kvm_vcpu *vcpu, u32 actio=
n,
>  				      const char *str);
> +bool kvmi_start_ss(struct kvm_vcpu *vcpu, gpa_t gpa, u8 access);
> =20
>  /* arch */
>  void kvmi_arch_update_page_tracking(struct kvm *kvm,
> @@ -274,6 +287,9 @@ int kvmi_arch_cmd_inject_exception(struct kvm_vcpu =
*vcpu, u8 vector,
>  				   u64 address);
>  int kvmi_arch_cmd_control_cr(struct kvm_vcpu *vcpu,
>  			     const struct kvmi_control_cr *req);
> +void kvmi_arch_start_single_step(struct kvm_vcpu *vcpu);
> +void kvmi_arch_stop_single_step(struct kvm_vcpu *vcpu);
> +u8 kvmi_arch_relax_page_access(u8 old, u8 new);
>  int kvmi_arch_cmd_control_msr(struct kvm_vcpu *vcpu,
>  			      const struct kvmi_control_msr *req);
>  int kvmi_arch_cmd_get_mtrr_type(struct kvm_vcpu *vcpu, u64 gpa, u8 *ty=
pe);

