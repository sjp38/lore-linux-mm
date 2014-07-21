Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9702B6B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 02:08:08 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so9163659pac.4
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:08:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fb3si13183361pab.58.2014.07.20.23.08.03
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 23:08:03 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v7 07/10] x86, mpx: decode MPX instruction to get bound violation information
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
	<1405921124-4230-8-git-send-email-qiaowei.ren@intel.com>
Date: Sun, 20 Jul 2014 23:07:59 -0700
In-Reply-To: <1405921124-4230-8-git-send-email-qiaowei.ren@intel.com> (Qiaowei
	Ren's message of "Mon, 21 Jul 2014 13:38:41 +0800")
Message-ID: <87ppgz2qio.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Qiaowei Ren <qiaowei.ren@intel.com> writes:
> +	 */
> +#ifdef CONFIG_X86_64
> +	insn->x86_64 = 1;
> +	insn->addr_bytes = 8;
> +#else
> +	insn->x86_64 = 0;
> +	insn->addr_bytes = 4;
> +#endif

How would that handle compat mode on a 64bit kernel?
Should likely look at the code segment instead of ifdef.
> +	/* Note: the upper 32 bits are ignored in 32-bit mode. */

Again correct for compat mode? I believe the upper bits 
are undefined.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
