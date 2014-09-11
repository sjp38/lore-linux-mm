Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 42BAF6B00A7
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 11:04:47 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so10129071pab.31
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:04:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id uk10si2043727pab.233.2014.09.11.08.04.45
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 08:04:45 -0700 (PDT)
Message-ID: <5411B9BD.2000900@intel.com>
Date: Thu, 11 Sep 2014 08:03:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> +
> +	return (void __user *)(unsigned long)(xsave_buf->bndcsr.cfg_reg_u &
> +			MPX_BNDCFG_ADDR_MASK);
> +}

I don't think casting a u64 to a ulong, then to a pointer is useful.
Just take the '(unsigned long)' out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
