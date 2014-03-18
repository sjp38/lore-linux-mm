Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6D40F6B00F6
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 06:25:53 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hm4so3397731wib.2
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 03:25:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ln4si7225630wic.64.2014.03.18.03.25.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 03:25:51 -0700 (PDT)
Date: Tue, 18 Mar 2014 11:25:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/9] mm: Provide new get_vaddr_pfns() helper
Message-ID: <20140318102550.GC10955@quack.suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
 <1395085776-8626-2-git-send-email-jack@suse.cz>
 <532760CF.10704@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532760CF.10704@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-media@vger.kernel.org

On Mon 17-03-14 13:53:35, Dave Hansen wrote:
> On 03/17/2014 12:49 PM, Jan Kara wrote:
> > +int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
> > +		   struct pinned_pfns *pfns)
> > +{
> ...
> > +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> > +		pfns->got_ref = 1;
> > +		pfns->is_pages = 1;
> > +		ret = get_user_pages(current, mm, start, nr_pfns, write, force,
> > +				     pfns_vector_pages(pfns), NULL);
> > +		goto out;
> > +	}
> 
> Have you given any thought to how this should deal with VM_MIXEDMAP
> vmas?  get_user_pages() will freak when it hits the !vm_normal_page()
> test on the pfnmapped ones, and jump out.  Shouldn't get_vaddr_pfns() be
> able to handle those too?
  It could and it doesn't seem as a big complication. Although none of the
converted drivers need this functionality, I guess it makes sense to
implement this to make the API more consistent. So I can have a look at it
for the next iteration.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
