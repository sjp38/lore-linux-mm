Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 221D26B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 03:08:53 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so82525932pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:08:52 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id if3si18989618pbc.192.2015.10.22.00.08.51
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 00:08:52 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH v11 01/14] fork: pass the dst vma to copy_page_range() and its sub-functions.
Date: Thu, 22 Oct 2015 15:08:38 +0800
Message-ID: <05e101d10c98$79a565e0$6cf031a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?'J=E9r=F4me_Glisse'?= <jglisse@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> -int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
> -			struct vm_area_struct *vma);
> +int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +		    struct vm_area_struct *dst_vma,
> +		    struct vm_area_struct *vma);
> 
s/vma/src_vma/ for easing readers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
