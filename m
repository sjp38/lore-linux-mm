Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD2B6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:20:29 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so2049713pac.3
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:20:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zw9si3043747pac.145.2014.07.23.09.20.27
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 09:20:28 -0700 (PDT)
Message-ID: <53CFE0C6.905@intel.com>
Date: Wed, 23 Jul 2014 09:20:22 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com> <1405921124-4230-9-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-9-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/20/2014 10:38 PM, Qiaowei Ren wrote:
> +	pr_debug("MPX BD base address %p\n", mm->bd_addr);
> +	return 0;
> +}

Please remove all of the pr_debug()s.  They're not appropriate for
common paths in production code.

There's another one in allocate_bt(), btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
