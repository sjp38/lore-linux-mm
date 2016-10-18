Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA8DC6B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 17:45:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so4683677qkf.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:45:45 -0700 (PDT)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id r74si2779396qke.70.2016.10.18.14.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 14:45:45 -0700 (PDT)
Date: Tue, 18 Oct 2016 17:44:58 -0400 (EDT)
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <541138814.5117130.1476827098471.JavaMail.zimbra@redhat.com>
In-Reply-To: <014b833f-a6e6-fcde-ecc5-2109bf2a0382@amd.com>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine> <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine> <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com> <59369ed7-9d35-baad-e0a9-ce4a62bc30bb@amd.com> <28535418.4145222.1476735296810.JavaMail.zimbra@redhat.com> <014b833f-a6e6-fcde-ecc5-2109bf2a0382@amd.com>
Subject: Re: [RFC PATCH v1 21/28] KVM: introduce KVM_SEV_ISSUE_CMD ioctl
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon guinot <simon.guinot@sequanux.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus walleij <linus.walleij@linaro.org>, linux-mm@kvack.org, paul gortmaker <paul.gortmaker@windriver.com>, hpa@zytor.com, dan j williams <dan.j.williams@intel.com>, aarcange@redhat.com, sfr@canb.auug.org.au, andriy shevchenko <andriy.shevchenko@linux.intel.com>, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross zwisler <ross.zwisler@linux.intel.com>, bp@suse.de, dyoung@redhat.com, thomas lendacky <thomas.lendacky@amd.com>, jroedel@suse.de, keescook@chromium.org, toshi kani <toshi.kani@hpe.com>, mathieu desnoyers <mathieu.desnoyers@efficios.com>, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.or


> > If I understanding correctly then you are recommending that instead of
> > exporting various functions from PSP drv we should expose one function
> > for the all the guest command handling (something like this).
> >
> > My understanding is that a user could exhaust the ASIDs for encrypted
> > VMs if it was allowed to start an arbitrary number of KVM guests.  So
> > we would need some kind of control.  Is this correct?
> 
> Yes, there is limited number of ASIDs for encrypted VMs. Do we need to
> pass the psp_fd into SEV_ISSUE_CMD ioctl or can we handle it from Qemu
> itself ? e.g when user asks to transition a guest into SEV-enabled mode
> then before calling LAUNCH_START Qemu tries to open /dev/psp device. If
> open() returns success then we know user has permission to communicate
> with PSP firmware.

No, this is a stateful mechanism and it's hard to implement.  Passing a
/dev/psp file descriptor is the simplest way to "prove" that you have
access to the device.

Thanks,

Paolo

> > If so, does /dev/psp provide any functionality that you believe is
> > dangerous for the KVM userspace (which runs in a very confined
> > environment)?  Is this functionality blocked through capability
> > checks?
> 
> I do not see /dev/psp providing anything which would be dangerous to KVM
> userspace. It should be safe to access /dev/psp into KVM userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
