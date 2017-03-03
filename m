Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 050906B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 16:15:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so140456604pgi.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 13:15:43 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0084.outbound.protection.outlook.com. [104.47.33.84])
        by mx.google.com with ESMTPS id e22si11625586pli.167.2017.03.03.13.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 13:15:43 -0800 (PST)
Subject: Re: [RFC PATCH v2 00/32] x86: Secure Encrypted Virtualization (AMD)
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <20170303203323.GA5305@bhelgaas-glaptop.roam.corp.google.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <d1ded08e-1a53-4762-84af-c5979bf9ed32@amd.com>
Date: Fri, 3 Mar 2017 15:15:30 -0600
MIME-Version: 1.0
In-Reply-To: <20170303203323.GA5305@bhelgaas-glaptop.roam.corp.google.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

Hi Bjorn,

On 03/03/2017 02:33 PM, Bjorn Helgaas wrote:
> On Thu, Mar 02, 2017 at 10:12:01AM -0500, Brijesh Singh wrote:
>> This RFC series provides support for AMD's new Secure Encrypted Virtualization
>> (SEV) feature. This RFC is build upon Secure Memory Encryption (SME) RFCv4 [1].
>
> What kernel version is this series based on?
>

This patch series is based off of the master branch of tip.
   Commit a27cb9e1b2b4 ("Merge branch 'WIP.sched/core'")
   Tom's RFC v4 patches (http://marc.info/?l=linux-mm&m=148725973013686&w=2)

Accidentally, I ended up rebasing SEV RFCv2 patches from updated SME v4 
instead of original SME v4. So you may need to apply patch [1]

[1] http://marc.info/?l=linux-mm&m=148857523132253&w=2

Optionally, I have posted the full git tree here [2]

[2] https://github.com/codomania/tip/branches

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
