Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A868AC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:04:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CFB32075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CFB32075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09B7E6B0007; Thu,  4 Apr 2019 06:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04BF96B0008; Thu,  4 Apr 2019 06:04:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA3986B0269; Thu,  4 Apr 2019 06:04:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD546B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 06:04:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so1102170edd.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 03:04:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M+m1rKqLrEEjKxqnjBVJinK8aaLGK7kUpm/Z2Wsf3EI=;
        b=VrWOaBMbZnmyasbtmrnEH253mWo9NYf6TTrpHN/CiC/8oSP8nmHn7l3jPoooWOtBGi
         McJYUEkerArde3n5obAXJt6LpLVFfTe4v0hGUxEG6ZwwE9NUCQEs02oVSCMVjXKHNJri
         DEpHSs0KulRd9TMD4cGWCqNNpCoO8khaesYHmkKuxJln0J0enIxb1FJvFiohmU/r9O8K
         Bo77JBsQ2/9t6G7UiTdwXMpOx87NzqgsFqGfK/d+B+jt+03ZgVbZ3EyB13vhksqBPVnF
         64MCw3nGXuz7DhbcO7fXxV+bEBSKU0rfLVCspcR7BS1/z/zCjhZJpYjBx4BFo1nzsTRM
         /i8A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXQ5g5RrycId9uP7SZg7qEsDbEWD5qwdD1IchpoNbuuXjem5cWq
	8F4lQSpHWLW/iOx82PgsmQAn9R9qorfohHnrS7A0HI25XgAPVmDomrF5kj6VgiCsdc/87ay2ZxE
	T82ZZlPOAdiweNiqRNz5BhF52xtPVowjqsqag6DfZa9wRE5gVCTr3HVC0lFFz/a8=
X-Received: by 2002:a05:6402:88a:: with SMTP id e10mr3124893edy.88.1554372248107;
        Thu, 04 Apr 2019 03:04:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbLvBZyUcvFL+ZfTikTkaxv+k+EEuahVfHL2s8MOc8UP/jGM2aARPHPDv1WwEk8v6V0uFv
X-Received: by 2002:a05:6402:88a:: with SMTP id e10mr3124842edy.88.1554372247163;
        Thu, 04 Apr 2019 03:04:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554372247; cv=none;
        d=google.com; s=arc-20160816;
        b=SCjfPHLItlnePIAq3OzqwJ0lJrixa4LpCH9C4lB7GNtYeUhxtQgU2hPGuAwmXkDPWn
         G1jMp7K6gN1fiRcAw85YO1Tu434JGcd7Q9m7kjcjL+SuR07U1oX9xer3nzejukSO4I3j
         GJFGUhS5r7hDysgEuvvTNHbmswFFJLvNUGF4eIqSpX8RZSV/874znwafRJ3vulIA+5ke
         +NCvBTED5e3cRttySXl2xeIN1n20PMHx31YuSGPTVXkfE8RlrCmS5JzbRKTeF7BLOmBk
         +TmLfdN8s0ThjCPHmoxe6DEY+hrGga3YWzmiYtbEJkfGYSg7p3oawhFbcp0CiyzdLvWZ
         Sy1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M+m1rKqLrEEjKxqnjBVJinK8aaLGK7kUpm/Z2Wsf3EI=;
        b=0+gcAAWIekHBUey+FSJ2lEvgjtgYUubnIuUqDQwNKkY2mW97vMffPce2oahRiewmSI
         mrvZUDRo0Ip4PjURqg4aWgw3P8nmhNgXoTNLLuEDr5uSgiFVkjfnJHUG6xbSRFAPNy5Y
         bb2H3QQ0i9f6Gd/trmI107E/u8nPLKpCVAQNh4qJq+PJbvrBQrqyc2v8x5pUVEgxpIkY
         eL69/I9Mh9nQM2g32sKuivGeffnSwVBCLDeGOXebLV4elZarrABe/xmn83Ol5XgJe7d2
         2Ch+0TAZJJ+uFK8HdF1s5fYARTY4T2juXd54Pz78tHOsS0LsyfpaMh2sl09uTs7EFIOj
         8s2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id s53si8020389edd.432.2019.04.04.03.04.06
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 03:04:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id ECC29480E; Thu,  4 Apr 2019 12:04:05 +0200 (CEST)
Date: Thu, 4 Apr 2019 12:04:05 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, david@redhat.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190404100403.6lci2e55egrjfwig@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
 <20190403084603.GE15605@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403084603.GE15605@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:46:03AM +0200, Michal Hocko wrote:
> On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > arch_add_memory, __add_pages take a want_memblock which controls whether
> > the newly added memory should get the sysfs memblock user API (e.g.
> > ZONE_DEVICE users do not want/need this interface). Some callers even
> > want to control where do we allocate the memmap from by configuring
> > altmap.
> > 
> > Add a more generic hotplug context for arch_add_memory and __add_pages.
> > struct mhp_restrictions contains flags which contains additional
> > features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> > currently) and altmap for alternative memmap allocator.
> > 
> > Please note that the complete altmap propagation down to vmemmap code
> > is still not done in this patch. It will be done in the follow up to
> > reduce the churn here.
> > 
> > This patch shouldn't introduce any functional change.
> 
> Is there an agreement on the interface here? Or do we want to hide almap
> behind some more general looking interface? If the former is true, can
> we merge it as it touches a code that might cause merge conflicts later on
> as multiple people are working on this area.

Uhm, I think that the interface is fine for now.
I thought about providing some callbacks to build the altmap layout, but I
realized that it was overcomplicated and I would rather start easy.
Maybe the naming could be changed to what David suggested, something like
"mhp_options", which actually looks more generic and allows us to stuff more
things into it should the need arise in the future.
But that is something that can come afterwards I guess.

But merging this now is not a bad idea taking into account that some people
is working on the same area and merge conflicts arise easily.
Otherwise re-working it every version is going to be a pita.

-- 
Oscar Salvador
SUSE L3

