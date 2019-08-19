Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D1F7C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:50:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A528206C1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:50:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A528206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6FEC6B0005; Mon, 19 Aug 2019 14:50:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF65C6B0006; Mon, 19 Aug 2019 14:50:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBD496B000C; Mon, 19 Aug 2019 14:50:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id 9408D6B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 14:50:42 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3C6FFF96
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:50:42 +0000 (UTC)
X-FDA: 75840068724.22.chair51_5d5535b33dc4a
X-HE-Tag: chair51_5d5535b33dc4a
X-Filterd-Recvd-Size: 4114
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:50:41 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 11:36:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,405,1559545200"; 
   d="scan'208";a="195592515"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by fmsmga001.fm.intel.com with ESMTP; 19 Aug 2019 11:36:44 -0700
Date: Mon, 19 Aug 2019 11:36:44 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Nicusor CITU <ncitu@bitdefender.com>
Cc: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>,
	"Zhang@vger.kernel.org" <Zhang@vger.kernel.org>,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Subject: Re: [RFC PATCH v6 55/92] kvm: introspection: add KVMI_CONTROL_MSR
 and KVMI_EVENT_MSR
Message-ID: <20190819183643.GB1916@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-56-alazar@bitdefender.com>
 <20190812210501.GD1437@linux.intel.com>
 <f9e94e9649f072911cc20129c2b633747d5c1df5.camel@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9e94e9649f072911cc20129c2b633747d5c1df5.camel@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 06:36:44AM +0000, Nicusor CITU wrote:
> > > +	void (*msr_intercept)(struct kvm_vcpu *vcpu, unsigned int msr,
> > > +				bool enable);
> > 
> > This should be toggle_wrmsr_intercept(), or toggle_msr_intercept()
> > with a paramter to control RDMSR vs. WRMSR.
> 
> Ok, I can do that.
> 
> 
> > > diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
> > > index 6450c8c44771..0306c7ef3158 100644
> > > --- a/arch/x86/kvm/vmx/vmx.c
> > > +++ b/arch/x86/kvm/vmx/vmx.c
> > > @@ -7784,6 +7784,15 @@ static __exit void hardware_unsetup(void)
> > >  	free_kvm_area();
> > >  }
> > >  
> > > +static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned int
> > > msr,
> > > +			      bool enable)
> > > +{
> > > +	struct vcpu_vmx *vmx = to_vmx(vcpu);
> > > +	unsigned long *msr_bitmap = vmx->vmcs01.msr_bitmap;

Is KVMI intended to play nice with nested virtualization?  Unconditionally
updating vmcs01.msr_bitmap is correct regardless of whether the vCPU is in
L1 or L2, but if the vCPU is currently in L2 then the effective bitmap,
i.e. vmcs02.msr_bitmap, won't be updated until the next nested VM-Enter.

> > > +
> > > +	vmx_set_intercept_for_msr(msr_bitmap, msr, MSR_TYPE_W, enable);
> > > +}
> > 
> > Unless I overlooked a check, this will allow userspace to disable
> > WRMSR interception for any MSR in the above range, i.e. userspace can
> > use KVM to gain full write access to pretty much all the interesting
> > MSRs. This needs to only disable interception if KVM had interception
> > disabled before introspection started modifying state.
> 
> We only need to enable the MSR interception. We never disable it -
> please see kvmi_arch_cmd_control_msr().

In that case, drop @enable and use enable_wrmsr_intercept() or something
along those lines for kvm_x86_ops instead of toggle_wrmsr_intercept().

