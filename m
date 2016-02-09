Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCAD6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 18:15:01 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so4483099wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:15:01 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id kc6si483010wjb.84.2016.02.09.15.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 15:15:00 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id g62so4482814wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:15:00 -0800 (PST)
Date: Wed, 10 Feb 2016 01:14:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm: Some arch may want to use HPAGE_PMD related
 values as variables
Message-ID: <20160209231457.GB22327@node.shutemov.name>
References: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20160209132608.814f08a0c3670b4f9d807441@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160209132608.814f08a0c3670b4f9d807441@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, mpe@ellerman.id.au, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 09, 2016 at 01:26:08PM -0800, Andrew Morton wrote:
> On Tue,  9 Feb 2016 21:41:44 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > @@ -660,6 +660,18 @@ static int __init hugepage_init(void)
> >  		return -EINVAL;
> >  	}
> >  
> > +	khugepaged_pages_to_scan = HPAGE_PMD_NR * 8;
> > +	khugepaged_max_ptes_none = HPAGE_PMD_NR - 1;
> 
> I don't understand this change.  We change the initialization from
> at-compile-time to at-run-time, but nothing useful appears to have been
> done.

It's preparation patch. HPAGE_PMD_NR is going to be based on variable on
Power soon. Compile-time is not an option.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
