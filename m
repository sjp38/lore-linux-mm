Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id AC1BC6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 00:13:07 -0400 (EDT)
Received: by mail-io0-f177.google.com with SMTP id 124so14748986iov.3
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 21:13:07 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id kc4si18583876igb.47.2016.03.22.21.13.05
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 21:13:07 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1458641159-13643-1-git-send-email-vaishali.thakkar@oracle.com> <0afe01d184b2$3f564ac0$be02e040$@alibaba-inc.com> <56F21395.8060608@oracle.com>
In-Reply-To: <56F21395.8060608@oracle.com>
Subject: Re: [PATCH 2/2] arch:mm: Use hugetlb_bad_size
Date: Wed, 23 Mar 2016 12:12:48 +0800
Message-ID: <0b0601d184ba$436808d0$ca381a70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vaishali Thakkar' <vaishali.thakkar@oracle.com>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Michal Hocko' <mhocko@suse.com>, 'Yaowei Bai' <baiyaowei@cmss.chinamobile.com>, 'Dominik Dingel' <dingel@linux.vnet.ibm.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Paul Gortmaker' <paul.gortmaker@windriver.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Chris Metcalf' <cmetcalf@ezchip.com>

> 
> Do you want me to send new version of the patchset breaking this patch in
> to separate patches?
> 
Yes.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
