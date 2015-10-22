Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7B89E6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:47:03 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so82655903pab.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:47:03 -0700 (PDT)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id lo9si19836775pab.201.2015.10.22.02.47.01
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 02:47:02 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH v11 07/14] HMM: mm add helper to update page table when migrating memory v2.
Date: Thu, 22 Oct 2015 17:46:47 +0800
Message-ID: <062101d10cae$91d986d0$b58c9470$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> This is a multi-stage process, first we save and replace page table
> entry with special HMM entry, also flushing tlb in the process. If
> we run into non allocated entry we either use the zero page or we
> allocate new page. For swaped entry we try to swap them in.
> 
Please elaborate why swap entry is handled this way.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
