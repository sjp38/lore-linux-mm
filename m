Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49D91280251
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:16:40 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n3so46943929lfn.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:16:40 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id r141si8063185lfr.359.2016.10.13.04.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 04:16:38 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x79so12178161lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:16:38 -0700 (PDT)
Subject: Re: [RFC PATCH v1 24/28] KVM: SVM: add SEV_LAUNCH_FINISH command
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190853894.9523.16890031242057232592.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <b7c63f07-7056-30db-0cd0-d103d51c4ff2@redhat.com>
Date: Thu, 13 Oct 2016 13:16:33 +0200
MIME-Version: 1.0
In-Reply-To: <147190853894.9523.16890031242057232592.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com



On 23/08/2016 01:28, Brijesh Singh wrote:
> +
> +	/* Iterate through each vcpus and set SEV KVM_SEV_FEATURE bit in
> +	 * KVM_CPUID_FEATURE to indicate that SEV is enabled on this vcpu
> +	 */
> +	kvm_for_each_vcpu(i, vcpu, kvm)
> +		svm_cpuid_update(vcpu);
> +

Do you need another call to sev_init_vmcb here?

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
