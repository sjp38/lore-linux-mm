Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4CD6C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:40:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C2512082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:40:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C2512082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19A2C6B0007; Thu,  4 Apr 2019 11:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149BB6B0008; Thu,  4 Apr 2019 11:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 060386B000A; Thu,  4 Apr 2019 11:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7C396B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:40:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p88so1640221edd.17
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ruUQXIeyvZQmoRZ1aXVp4fa54nBuEE0mXXW40vQ7J04=;
        b=Uce726DhIv+Nq1gfql2rmibPDevYKCEJ/VWeKKSpBO3nv24Vsu+Qk5NZPHdtZIvAne
         4W4r7QpvmETyAodM7us8+zCqExySmJJSeRuq9Odz9+DAubDLIVN8EFhFHfVdnDj3Mqtv
         5vutDPgMO3JrfMHy7Lbl2TXatJLQbMXizc4Axu4+1h/JUB1OkDzSOebSDmy3zEfMnn1E
         bPoJ8p6uAMwzCp8aovt9R6wcvwWKKQj9cOklTr5LyqOKVwSPJRpJGn0C2+K+tF/YDvFP
         mGa1tWcGERRXVQ9h32+WjSRmJrmZ742a5gQFlT+ExOG3mXS1jZbN/a1z8jLsNQxDZe6Y
         9N9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU4iJUcYJV4igB79s8svyh8dSm+JFaNZXrxNhMaBJrtb5TsAWoX
	tKKmeWPCy7NBwwLpWiKfcuQM18m/U5JeLyepA4tbdIxDtWFGX8JfMQ2S02E/2cK5pqvEFOnSrBH
	pUEd9hPiv/+qXVK7nTA2S57F+9SHydV51+CvXHgG/KovqGcvW21UjjDHoylGNnxLspw==
X-Received: by 2002:a17:906:46d1:: with SMTP id k17mr4144958ejs.104.1554392411055;
        Thu, 04 Apr 2019 08:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRmYeuHUP/nUtD6ZprfoX+qV+VKAM3eAeOzINKT3W6jH+o5UebxO9rrS+h7xQw+YkngtSW
X-Received: by 2002:a17:906:46d1:: with SMTP id k17mr4144899ejs.104.1554392410025;
        Thu, 04 Apr 2019 08:40:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554392410; cv=none;
        d=google.com; s=arc-20160816;
        b=bEF99Wtfr9ld0o5pF+dl7b9drHFCE0dU58DLn4GfNlRkW1uu7KabWVEQpyjsvL4j/G
         tREFH7uYjzTliJ7ZqBsIrNgkn05q4ewa98bdwmoYeECKLDhdBTmJo5W/kBbbl+4+AP8V
         VSpjrNytc+EEbULu4FPTVabnSDYQI3BcH0W0lXRHwCZ0aWCKrH939PRBuztea9VfrdIg
         9y21SpsulFSMY56jn35EVXaSu6qdus0WrwA6E4wIDZt4w8V43P0e83zWOs9u+V6cVxtk
         /QVSAPbWFQKy/1Y8iue/iMkw4B1Z4zNkhD17Hu9LfDk4BcF/YuI/xAclRnYpeKKAwkFp
         FmSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ruUQXIeyvZQmoRZ1aXVp4fa54nBuEE0mXXW40vQ7J04=;
        b=h38c4ejX2g96VQwMDnHF6MNZV853Ho/OBRIf4V/vgDAgxGfEiqjWwJIgMkscjIJxhO
         h7cxJmckMxuQcaZmUWbK4ScXh6pfvWfG5i7rk5uvwu8j1Pz85Y32VdGbwLonOfbr+tBq
         07nF4FVoI7tClvYtjyMJ42C+9p00URnnwnBUyhoDmVcgFceczVYNqj3qS6LI1imgqEfo
         7pccQ/JE1uLbv8dOjQx7X1JS93xmdilt7ul5K08bMIAlOhdcePkp46Ayf6K7PDPI3evX
         2A4fiMvVwS16q401sFg8OHMUbiolipOygxqbSIWOqPzeQztoC5eQXs+gcm9IhgVRCkJg
         3kDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id k13si492374edr.161.2019.04.04.08.40.09
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 08:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 3CFB14824; Thu,  4 Apr 2019 17:40:09 +0200 (CEST)
Date: Thu, 4 Apr 2019 17:40:09 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
Message-ID: <20190404154006.ywtpwb3c3frkajzk@d104.suse.de>
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-2-osalvador@suse.de>
 <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
 <20190404132506.kaqzop4qs6m56plu@d104.suse.de>
 <7874ef85-adc7-95a8-87f4-1f15eb21c677@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7874ef85-adc7-95a8-87f4-1f15eb21c677@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 04:47:43PM +0200, David Hildenbrand wrote:
> On 04.04.19 15:25, Oscar Salvador wrote:
> > On Thu, Apr 04, 2019 at 03:18:00PM +0200, David Hildenbrand wrote:
> >>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >>> index f206b8b66af1..d8a3e9554aec 100644
> >>> --- a/mm/memory_hotplug.c
> >>> +++ b/mm/memory_hotplug.c
> >>> @@ -1451,15 +1451,11 @@ static int
> >>>  offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
> >>>  			void *data)
> >>>  {
> >>> -	__offline_isolated_pages(start, start + nr_pages);
> >>> -	return 0;
> >>> -}
> >>> +	unsigned long offlined_pages;
> >>>  
> >>> -static void
> >>> -offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
> >>> -{
> >>> -	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
> >>> -				offline_isolated_pages_cb);
> >>> +	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
> >>> +	*(unsigned long *)data += offlined_pages;
> >>
> >> unsigned long *offlined_pages = data;
> >>
> >> *offlined_pages += __offline_isolated_pages(start, start + nr_pages);
> > 
> > Yeah, more readable.
> > 
> >> Only nits
> > 
> > About the identation, I double checked the code and it looks fine to me.
> > In [1] looks fine too, might be your mail client?
> > 
> > [1] https://patchwork.kernel.org/patch/10885571/
> 
> Double checked, alignment on the parameter on the new line is very weird.

Uhm, are not you confused because we removed the "while (off...)", and
"ret =" gets idented right below "/*check again*".

Try to apply the patch and check whether you still see the issue.
I just checked out the branch and it looks fine to me.

> And both lines cross 80 lines per line ... nit :)

Yeah, 81 characters, but I decided to go with that rather than start doing
tricky things to accomplish 80 characters.
Maybe Andrew agrees, or he might slap me.

-- 
Oscar Salvador
SUSE L3

