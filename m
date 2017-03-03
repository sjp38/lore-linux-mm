Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6AC6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 12:17:56 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so133550136pga.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 09:17:56 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d13si11163139pln.274.2017.03.03.09.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 09:17:55 -0800 (PST)
Subject: Re: [PATCH 2/4] thp: fix MADV_DONTNEED vs. numa balancing race
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <929b3844-aec2-0111-fef7-8002f9d4e2b9@intel.com>
Date: Fri, 3 Mar 2017 09:17:49 -0800
MIME-Version: 1.0
In-Reply-To: <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2017 07:10 AM, Kirill A. Shutemov wrote:
> @@ -1744,7 +1744,39 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	if (prot_numa && pmd_protnone(*pmd))
>  		goto unlock;
>  
> -	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);

Are there any remaining call sites for pmdp_huge_get_and_clear_notify()
after this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
