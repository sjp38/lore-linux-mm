Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668F6C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 08:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1441E20878
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 08:24:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1441E20878
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6329E8E00F2; Fri, 22 Feb 2019 03:24:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DFBE8E00EB; Fri, 22 Feb 2019 03:24:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D00A8E00F2; Fri, 22 Feb 2019 03:24:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7B068E00EB
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 03:24:43 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o9so610596edh.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 00:24:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rm7/EB2Ec7OOSlIURCaFLj4q48F4NfauFSf3TOQQWSk=;
        b=n3x/AmffNzWPqkYPNS7y5Ui3V/RBqdTkATOlOW/FmNkDY5QH5SU3Zo2rsJCNgL6phs
         aDPFKrOpnkvvj1ooMCDFZ7bFRs6BNlYuiC2SR6eAyZZGloaIbyRTaaG6VlwypSC5IVqC
         0jnxLUX35fe12sUliNO3eKA2I5tv4vv1ipSbDXlsvOp1zNiEQdKOXHobszNP+9Z/JKa3
         6rK/XVz3kVzI5R0h/wW04kZwbdXBurfHTp6CABKABEvdOqVc+qmtw31JM59Sp3WQkBuJ
         2G1wn5HX1jA4AQY3XyD5r1vsRAm9Eq0+MeGghiaMusMsAwmU6ZF9G4yc8sdBJ9jrH2Il
         ManQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuYuy2szeswCajg2V/Ne0jnyTZKaTsm5FFByTN0Kd6qCuaZn9qr3
	SXEjHkK5Tu0ULcQUcSbTv/sXI9Ot00N1yY6W1ANKEW9Syd7WWz1XWAefgv2o5T5hl3xLqha5+mL
	WNXod4wvdSmXR1Gwt2kl5XRN5yhqXhzt7t9J6YsQiYDKLzj/6ELkndbsblbh35eKqoQ==
X-Received: by 2002:a05:6402:650:: with SMTP id u16mr2167431edx.148.1550823883362;
        Fri, 22 Feb 2019 00:24:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbE+ZcEx9LkiHs1uWCCGFSRMHU3Wy5BgmTfT6PxgE6rl6tA9q4iI2joYZxqSZnju9MeM3OO
X-Received: by 2002:a05:6402:650:: with SMTP id u16mr2167359edx.148.1550823882021;
        Fri, 22 Feb 2019 00:24:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550823882; cv=none;
        d=google.com; s=arc-20160816;
        b=y2aHPPYPHacIZREjXTp94YdCL7jpebU/RKuNTHKd2nkNZ1mTCn/eTAo7yjw+3tf4bY
         NkUmxIAg7a+gqPj+fzOGPG91X6mYX00EBf+cMSzsVAnyRLCbitD6MfBwv83qhhp+9zxP
         9ilIKBfHQtdo1AzEdeJ1W/hMrxt38GpfZzPKXZEZkEZWEhNgz2RzUxxqLmo85//cBYye
         2RaYy0evukJyN53Xh4vPgkM3bXEiN1V5o/iFFrFelGiyMdF4usxaJt7CZaEzaN8JiHOR
         jz17UsdJSqfzPAh+mJ6YK8Xf/yQjdSxBLHpsWB/CjS16k/wefl0iYHGaNCttq3lVLH68
         NfSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rm7/EB2Ec7OOSlIURCaFLj4q48F4NfauFSf3TOQQWSk=;
        b=hy+Cqh4QsoWOvfkidW4mflyicYRhbYB1w8rO9kOxqAVl9SUYPa+Jxx6V8+e5VBmrRu
         P3Vylw8wqs+1+j/EuPoOS6TX7L8AB1hZ2Zg78JzAM+HI6q0d4kskJaZmL6lBXBpxhTPB
         WCnRP6jyB5JGZ7xqRWsWObhjily90w9maGQakPa178GZILI4+b6HIpO6Y4GlqPL28tit
         DPTqroORWwGevWrSNZXfOgw4DOkqXw4aakMiZcM9VJJyEGZQk7eiKHiOqZ5+NMKWWJF5
         Sifohc7+1daikLm3WXneLp9zrQ1E+q1j1qVfAuRQQMCjG90QhwPgBeJfQyAkgUuu2DhH
         wHpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id k27si102993ejb.162.2019.02.22.00.24.41
        for <linux-mm@kvack.org>;
        Fri, 22 Feb 2019 00:24:42 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 34F4E435E; Fri, 22 Feb 2019 09:24:41 +0100 (CET)
Date: Fri, 22 Feb 2019 09:24:40 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
	david@redhat.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190222082433.qqcfbpuc7guqzsj6@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
 <c4fc87f2-9ff8-3bc1-e990-da97c56ba18f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4fc87f2-9ff8-3bc1-e990-da97c56ba18f@oracle.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 02:12:19PM -0800, Mike Kravetz wrote:
> I suspect the reason for the check is that it was there before the ability
> to migrate gigantic pages was added, and nobody thought to remove it.  As
> you say, the likelihood of finding a gigantic page after running for some
> time is not too good.  I wonder if we should remove that check?  Just trying
> to create a gigantic page could result in a bunch of migrations which could
> impact the system.  But, this is the result of a memory offline operation
> which one would expect to have some negative impact.

The check was introduced by ("ab5ac90aecf56:mm, hugetlb: do not rely on 
overcommit limit during migration), but I would have to do some research
to the changes that came after.
I am not really sure about removing the check.
I can see that is perfectly fine to migrate gigantic pages as long as the
other nodes can back us up, but trying to allocate them at runtime seems that
is going to fail more than succeed. I might be wrong of course.
I would rather leave it as it is.

> 
> > In that situation, we will keep looping forever because scan_movable_pages()
> > will give us the same page and we will fail again because there is no node
> > where we can dequeue a gigantic page from.
> > This is not nice, and I wish we could differentiate a fatal error from a
> > transient error in do_migrate_range()->migrate_pages(), but I do not really
> > see a way now.
> 
> Michal may have some thoughts here.  Note that the repeat loop does not
> even consider the return value from do_migrate_range().  Since this the the
> result of an offline, I am thinking it was designed to retry forever.  But,
> perhaps there are some errors/ret codes where we should give up?

Well, it has changed a bit over the time.
It used to be a sort of retry-timer before, where we bailed out after
a while.
But it turned out to be too easy to fail and the timer logic was removed
in (ecde0f3e7f9ed: mm, memory_hotplug: remove timeout from __offline_memory).

I think that returning a valuable error code from migrate_pages back to
do_migrate_range has always been a bit difficult.
What should be considered a fatal error?

And for the purpose here, the error we would return is -ENOMEM when we do not
have nodes containing spare gigantic pages.
Maybe that could be one of the reasons to bail out.
If we are short of memory, offlining more memory will not do anything but apply
more pressure to the system.

But I am bit worried to actually start backing off due to that, since at the
moment, the only way to back off from offlining operation is to send a signal
to the process.

I would have to think a bit more, but another possibility that comes to my mind
is:

*) Try to check whether the hstate has free pages in has_unmovable_pages.
   If not report the gigantic page as unmovable.
   This would follow the check hugepage_migration_supported() in has_unmovable_pages.

If not, as I said, we could leave it as it is.
Should be sysadmin's responsability to check in advance that the system is ready
to take over the memory to be offlined.

> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index d5f7afda67db..04f6695b648c 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> >  		if (!PageHuge(page))
> >  			continue;
> >  		head = compound_head(page);
> > -		if (hugepage_migration_supported(page_hstate(head)) &&
> > -		    page_huge_active(head))
> > +		if (page_huge_active(head))
> 
> I'm confused as to why the removal of the hugepage_migration_supported()
> check is required.  Seems that commit aa9d95fa40a2 ("mm/hugetlb: enable
> arch specific huge page size support for migration") should make the check
> work as desired for all architectures.

has_unmovable_pages() should already cover us in case the hstate is not migrateable:

<--
if (PageHuge(page)) {
	struct page *head = compound_head(page);
	unsigned int skip_pages;
	
	if (!hugepage_migration_supported(page_hstate(head)))
		goto unmovable;
	
	skip_pages = (1 << compound_order(head)) - (page - head);
	iter += skip_pages - 1;
	continue;
}
-->

Should not be migrateable, we report unmovable pages within the range,
start_isolate_page_range() will report the failure to __offline_pages() and
so we will not go further.

-- 
Oscar Salvador
SUSE L3

