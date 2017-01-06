Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D14106B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 03:08:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so2260625wmf.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 00:08:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 21si513979wry.50.2017.01.06.00.08.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 00:08:41 -0800 (PST)
Date: Fri, 6 Jan 2017 09:08:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] mm patches review bandwidth
Message-ID: <20170106080839.GA5556@dhcp22.suse.cz>
References: <20170105153737.GV21618@dhcp22.suse.cz>
 <b1a870cc-608f-7613-c29f-9eb2a3518f8f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1a870cc-608f-7613-c29f-9eb2a3518f8f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Thu 05-01-17 17:43:38, Mike Kravetz wrote:
> On 01/05/2017 07:37 AM, Michal Hocko wrote:
[...]
> > Another problem, somehow related, is that there are areas which have
> > evolved into a really bad shape because nobody has really payed
> > attention to them from the architectural POV when they were merged. To
> > name one the memory hotplug doesn't seem very healthy, full of kludges,
> > random hacks and fixes for fixes working for a particualr usecase
> > without any longterm vision. We have allowed to (ab)use concepts like
> > ZONE_MOVABLE which are finding new users because that seems to be the
> > simplest way forward. Now we are left with fixing the code which has
> > some fundamental issues because it is used out there. Are we going to do
> > anything about those? E.g. generate a list of them, discuss how to make
> > that code healthy again and do not allow new features until we sort that
> > out?
> 
> hugetlb reservation processing seems to be one of those areas.  I certainly
> have been guilty of stretching the limits of the current code to meet the
> demands of new functionality.  It has been my desire to do some rewrite or
> rearchitecture in this area.

I think that it would be really useful to start by a throughout design
documentation of the current code before any rewrite. I believe this
will already tell us a lot of the design complexities and shortcomings
already.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
