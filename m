Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5638C6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:02:19 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so1852224pdi.11
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:02:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 4si1508202pdm.155.2014.07.23.09.02.16
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 09:02:17 -0700 (PDT)
Message-ID: <53CFDC79.8040804@intel.com>
Date: Wed, 23 Jul 2014 09:02:01 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 03/10] x86, mpx: add macro cpu_has_mpx
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com> <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com> <53CE8EEC.2090402@intel.com> <9E0BE1322F2F2246BD820DA9FC397ADE0170079E@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE0170079E@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/22/2014 07:35 PM, Ren, Qiaowei wrote:
> The checking about MPX feature should be as follow:
> 
>         if (pcntxt_mask & XSTATE_EAGER) {
>                 if (eagerfpu == DISABLE) {
>                         pr_err("eagerfpu not present, disabling some xstate features: 0x%llx\n",
>                                         pcntxt_mask & XSTATE_EAGER);
>                         pcntxt_mask &= ~XSTATE_EAGER;
>                 } else {
>                         eagerfpu = ENABLE;
>                 }
>         }
> 
> This patch was merged into kernel the ending of last year (https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e7d820a5e549b3eb6c3f9467507566565646a669 )

Should we be doing a clear_cpu_cap(X86_FEATURE_MPX) in here?

This isn't major, but I can't _ever_ imagine a user being able to track
down why MPX is not working from this message.  Should we spruce it up
somehow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
