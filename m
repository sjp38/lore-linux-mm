Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 619956B038B
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 15:51:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c143so9546334wmd.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 12:51:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 98si16187463wrk.228.2017.03.03.12.51.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 12:51:48 -0800 (PST)
Date: Fri, 3 Mar 2017 21:51:30 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 00/32] x86: Secure Encrypted Virtualization (AMD)
Message-ID: <20170303205130.6xjinxnrlgmvxu2a@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <20170303203323.GA5305@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170303203323.GA5305@bhelgaas-glaptop.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Fri, Mar 03, 2017 at 02:33:23PM -0600, Bjorn Helgaas wrote:
> On Thu, Mar 02, 2017 at 10:12:01AM -0500, Brijesh Singh wrote:
> > This RFC series provides support for AMD's new Secure Encrypted Virtualization
> > (SEV) feature. This RFC is build upon Secure Memory Encryption (SME) RFCv4 [1].
> 
> What kernel version is this series based on?

Yeah, see that mail in [1]:

https://lkml.kernel.org/r/20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net

"This patch series is based off of the master branch of tip.
  Commit a27cb9e1b2b4 ("Merge branch 'WIP.sched/core'")"

$ git describe a27cb9e1b2b4
v4.10-rc7-681-ga27cb9e1b2b4

So you need the SME pile first and then that SVE pile. But the first
patch needs refreshing as it is using a different base than the SME
pile. :-)

Tom, Brijesh, perhaps you guys could push a full tree somewhere - github
or so - for people to pull, in addition to the patchset on lkml.

Thanks.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
