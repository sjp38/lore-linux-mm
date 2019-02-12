Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A353C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:45:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4076D2184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:45:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4076D2184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF5588E0013; Tue, 12 Feb 2019 08:45:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7A148E0012; Tue, 12 Feb 2019 08:45:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B43688E0013; Tue, 12 Feb 2019 08:45:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9768E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:45:52 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so2389358edz.15
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:45:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IgFJE3uXMruvy0WZ0W8RxdbuSxRRzmzJVTobVc1d0IQ=;
        b=jdY4E0pRPN2pRAhLIcmG+hbMed6o7f3NIDEgqKNdyOWhwdImdEGBS3aVFhiyolKeNl
         uVOJeG4crz8mQoULxUwBEyuqJUp5j81G8hS+RmSJb81GC0uH+DKX+nt0w6WK2BhhfpkS
         Y5JUCL7VJcXAe8S2Lti6Nqp7MvgNoaFnfhyzl27U5y7jwx16wOrZNZAEvv9yRR8tXpts
         OJvRueqEdih4Qx7dLhDdikXKn5l60REAkunPAYpMx2AVwMxBPxl1mVkAdcsmTOzXjS3K
         ZpzV+6MlCVdOc4MJEEW2pwztYWAv1jEn6I3psJlFgJ9kMVzwb+fEOqZf1UGp8oZm7D3i
         PsEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuaBc4roNHKneLhKzQ0yfmhBYM3LQTwLhA9iVSxz9eojfLVFz6q2
	n3iBq5I6hjmwmTo5R7e8DXtXAmYMAzf6Kwbeo+WgH5uYzI3GS039v+DLaRCuegVMeQogNrb0SLp
	aWBh3ZZzQTKvgr6YDrqfpbuf7N4neJNV5JAMtf0dZPzHb3GLOodCvMvyjXmt4k0XNlA==
X-Received: by 2002:a50:c2d9:: with SMTP id u25mr3192881edf.280.1549979151939;
        Tue, 12 Feb 2019 05:45:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpTvJpskhCa1nN6yrFHBijQZsuOQ7JZgRdfkEnfCz6pHy/K8Ktt68GRTr/ewdkVlzYVFHF
X-Received: by 2002:a50:c2d9:: with SMTP id u25mr3192827edf.280.1549979151112;
        Tue, 12 Feb 2019 05:45:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549979151; cv=none;
        d=google.com; s=arc-20160816;
        b=U1T6MEevJNacfREr/rO42Mzms7r2V1PXqCr3XZpAXptMNZ+HGni6L+s52K8dmUoHjC
         a4TSQ2DsbiYzQlpDi68a+LJ2D5koxWWnPLjObnbMyDLExPYDNyikX+1+IMGSY6lMs7rx
         y51baORW1N1WzGV1o3knjo8bKlEtxxv8FgByBWfKMrZxTEPwLT+s6TKkyscEDUhO7ubI
         JDixU/jSEdvwfi20dsxQ2IeARAb7CgKyzP4+jJnIQ0rFr7oaUaDVVl7uMcLB7XT860Nf
         L2yCveiJtB7v23KIcBKeD7TK9XUc0PtdOWZ2uA3We4Mj+r+k7yKrzztxW9LWCviKdIhZ
         8GGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IgFJE3uXMruvy0WZ0W8RxdbuSxRRzmzJVTobVc1d0IQ=;
        b=OIq/XBWf2E8BrI6S9wYjqrI9UDQWTyUk+boIivDlKChYZiZgF+bX0wsMbWlPbIIZCX
         nWVDjqDYhdYuw5smA/WeJIgAm4rt/hfl6OYmT51lm6UeMYHTWjDJps8DcxOtwb2R8DaY
         SvZwIaMy7/LeIXYE1pdT0WYT9XiLdfILVeU6PIwgAbFnnJWQq4xjQfD7ELsLsenqcj/Q
         2ttKsPcACgv/S+Rc7tv7CcMN6um9sEEL7kLO327r3Z6M1ZfWnlH634+qzv89d99/Bo2x
         FpC2PtldavRTuMPdcd7sBq2xy/B+zHCWaZQQCBDuIsC3BTpiLWa9FmMDaXmoyqCwzO/G
         YpWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id q2-v6si2712997eja.38.2019.02.12.05.45.50
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 05:45:51 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 1FF22423F; Tue, 12 Feb 2019 14:45:49 +0100 (CET)
Date: Tue, 12 Feb 2019 14:45:49 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, david@redhat.com, anthony.yznaga@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212083329.GN15609@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 09:33:29AM +0100, Michal Hocko wrote:
> >  
> >  		if (PageHuge(page)) {
> >  			struct page *head = compound_head(page);
> > -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> >  			if (compound_order(head) > PFN_SECTION_SHIFT) {
> >  				ret = -EBUSY;
> >  				break;
> >  			}
> 
> Why are we doing this, btw? 

I assume you are referring to:

> >                     if (compound_order(head) > PFN_SECTION_SHIFT) {
> >                             ret = -EBUSY;
> >                             break;
> >                     }

I thought it was in case we stumble upon a gigantic page, and commit
(c8721bbbdd36 mm: memory-hotplug: enable memory hotplug to handle hugepage)
confirms it.

But I am not really sure if the above condition would still hold on powerpc,
I wanted to check it but it is a bit more tricky than it is in x86_64 because
of the different hugetlb sizes.
Could it be that the above condition is not true, but still the order of that
hugetlb page goes beyond MAX_ORDER? It is something I have to check.

Anyway, I think that a safer way to check this would be using hstate_is_gigantic(),
which checks whether the order of the hstate goes beyond MAX_ORDER.
In the end, I think that all we care about is if we can get the pages to migrate
to via the buddy allocator, since gigantic pages need to use another method.

Actually, alloc_migrate_huge_page() checks for it:

<---
static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
		int nid, nodemask_t *nmask)
{

	if (hstate_is_gigantic(h))
		return NULL;
--->

Another thing is that AFAICS, as long as the memblock we try to offline contains
a gigantic page, it will not be able to be offlined.
Moreover, the -EBUSY we return in that case is not checked anywhere, although that
is not really an issue because scan_movable_pages will skip it in the next loop.

Now, this is more rambling than anything:
Maybe I am missing half of the picture, but I have been thinking for a while whether
we could do better when it comes to gigantic pages vs hotplug.
I think that we could try to migrate those in case any of the other nodes
have a spare pre-allocated gigantic page.

-- 
Oscar Salvador
SUSE L3

