Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 89FAC6B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 16:31:39 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id td3so3892729pab.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 13:31:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q90si6529701pfa.198.2016.03.23.13.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 13:31:38 -0700 (PDT)
Date: Wed, 23 Mar 2016 13:31:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] arch:mm: Use hugetlb_bad_size
Message-Id: <20160323133137.944775ef2e70a8a505aabd24@linux-foundation.org>
In-Reply-To: <0b0601d184ba$436808d0$ca381a70$@alibaba-inc.com>
References: <1458641159-13643-1-git-send-email-vaishali.thakkar@oracle.com>
	<0afe01d184b2$3f564ac0$be02e040$@alibaba-inc.com>
	<56F21395.8060608@oracle.com>
	<0b0601d184ba$436808d0$ca381a70$@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Vaishali Thakkar' <vaishali.thakkar@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Michal Hocko' <mhocko@suse.com>, 'Yaowei Bai' <baiyaowei@cmss.chinamobile.com>, 'Dominik Dingel' <dingel@linux.vnet.ibm.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Paul Gortmaker' <paul.gortmaker@windriver.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Chris Metcalf' <cmetcalf@ezchip.com>

On Wed, 23 Mar 2016 12:12:48 +0800 "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> > 
> > Do you want me to send new version of the patchset breaking this patch in
> > to separate patches?
> > 
> Yes.

That would be a bit of a pain because then each arch maintainer will
need to check that the [1/1] patch is merged.  In fact the arch
maintainer can't actually merge the arch patch locally without having
[1/1] present.

Simply acking this patch would make life much simpler, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
