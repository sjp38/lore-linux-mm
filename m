Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E5B8C6B0036
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 18:58:03 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so2174276pde.17
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:58:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id jg1si10576676pbb.40.2014.09.12.15.58.02
        for <linux-mm@kvack.org>;
        Fri, 12 Sep 2014 15:58:02 -0700 (PDT)
Message-ID: <54137A79.6060602@intel.com>
Date: Fri, 12 Sep 2014 15:58:01 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 04/10] x86, mpx: hook #BR exception handler to allocate
 bound tables
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-5-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-5-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> +static int allocate_bt(long __user *bd_entry)
> +{
> +	unsigned long bt_addr, old_val = 0;
> +	int ret = 0;
> +
> +	bt_addr = mpx_mmap(MPX_BT_SIZE_BYTES);
> +	if (IS_ERR((void *)bt_addr))
> +		return bt_addr;
> +	bt_addr = (bt_addr & MPX_BT_ADDR_MASK) | MPX_BD_ENTRY_VALID_FLAG;

Qiaowei, why do we need the "& MPX_BT_ADDR_MASK" here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
