Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8830C6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:34:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q3so6726144pgv.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:34:51 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q2si4606773pgp.400.2017.12.07.18.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 18:34:50 -0800 (PST)
Date: Fri, 8 Dec 2017 10:27:05 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH v3] mm, thp: introduce generic transparent huge page
 allocation interfaces
Message-ID: <20171208022704.7kcoky7si2suqelt@intel.com>
References: <1512644059-24329-1-git-send-email-changbin.du@intel.com>
 <20171207154519.df3f8218f8dbe05f95a2bc42@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207154519.df3f8218f8dbe05f95a2bc42@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: changbin.du@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Hi Andrew,
On Thu, Dec 07, 2017 at 03:45:19PM -0800, Andrew Morton wrote:
> On Thu,  7 Dec 2017 18:54:19 +0800 changbin.du@intel.com wrote:
> 
> > From: Changbin Du <changbin.du@intel.com>
[snip]
 > -static inline void prep_transhuge_page(struct page *page) {}
> > +#define alloc_transhuge_page_vma(gfp_mask, vma, addr) NULL
> > +#define alloc_transhuge_page_nodemask(gfp_mask, preferred_nid, nmask) NULL
> > +#define alloc_transhuge_page_node(nid, gfp_maskg) NULL
> > +#define alloc_transhuge_page(gfp_mask) NULL
> 
> Ugly.  And such things can cause unused-variable warnings in calling
> code.  Whereas
> 
> static inline struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> 			struct vm_area_struct *vma, unsigned long addr)
> {
> 	return NULL;
> }
> 
> will avoid such warnings.
>
Thanks for pointing out, I will update it.
   
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Thanks,
Changbin Du

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
