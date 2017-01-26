Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDA746B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 22:00:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so293878835pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 19:00:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z72si25229902pgd.233.2017.01.25.19.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 19:00:02 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0Q2wd8g067061
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 22:00:02 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 286xt45y3r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 22:00:02 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 26 Jan 2017 13:00:00 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id CF15E2CE8054
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:59:58 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0Q2xo3V13959266
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:59:58 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0Q2xQYl002592
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:59:26 +1100
Date: Wed, 25 Jan 2017 18:58:58 -0800
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 09/12] mm, uprobes: convert __replace_page() to
 page_check_walk()
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-10-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20170124162824.91275-10-kirill.shutemov@linux.intel.com>
Message-Id: <20170126025858.GC11569@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [2017-01-24 19:28:21]:

> For consistency, it worth converting all page_check_address() to
> page_check_walk(), so we could drop the former.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  kernel/events/uprobes.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 1e65c79e52a6..6dbaa93b22fa 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -153,14 +153,19 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  				struct page *old_page, struct page *new_page)
>  {
>  	struct mm_struct *mm = vma->vm_mm;

I thought the subject is a bit misleading, it looks as if we are
replacing __replace_page. Can it be changed to
"Convert __replace_page() to use page_check_walk()" ?

Otherwise looks good to me.

Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
