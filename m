Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE8896B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:21:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g64so249976340pfb.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:21:53 -0700 (PDT)
Received: from out4133-98.mail.aliyun.com (out4133-98.mail.aliyun.com. [42.120.133.98])
        by mx.google.com with ESMTP id zx11si49154837pab.234.2016.05.30.01.21.52
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 01:21:52 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001801d1ba44$dc78c5e0$956a51a0$@alibaba-inc.com>
In-Reply-To: <001801d1ba44$dc78c5e0$956a51a0$@alibaba-inc.com>
Subject: Re: [RFC PATCH 3/4] mm/mmu_gather: Track page size with mmu gather and force flush if page size change
Date: Mon, 30 May 2016 16:21:34 +0800
Message-ID: <001a01d1ba4c$47742590$d65c70b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
> index 2ac8fe202e9a..3ca36c111b47 100644
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -112,6 +112,7 @@ struct mmu_gather {
>  	 * that that we can adjust the range after the flush
>  	 */
>  	unsigned long addr;
> +	int page_size;

Add a comment for it please.

Hillf
>  };


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
