Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57FC16B2BFF
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:52:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w80-v6so81861wmw.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 13:52:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b134-v6sor1337891wmd.88.2018.08.23.13.52.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 13:52:50 -0700 (PDT)
Date: Thu, 23 Aug 2018 22:52:48 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
Message-ID: <20180823205248.GA22452@techadventures.net>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
 <20180823132526.GL29735@dhcp22.suse.cz>
 <20180823140053.GC14924@techadventures.net>
 <20180823191729.GQ29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823191729.GQ29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 09:17:29PM +0200, Michal Hocko wrote:
> And how exactly does it help to check for the smaller vs. a larger number?
> Both are O(1) operations AFAICS. __highest_present_section_nr makes
> perfect sense when we iterate over all sections or similar operations
> where it smaller number of iterations really makes sense.

Sure, improvement/optimization was not really my point, a comparasion is
a comparasion.
The gain, if any, would be because we would catch
non present sections sooner before calling to present_section().
In the case that __highest_present_section_nr differs from
NR_MEM_SECTIONS, of course.

I thought it would make more sense given the nature of the function itself.

The only thing I did not like much was that we need to export the symbol, though.
So, as you said, the price might be too hight for what we get.

-- 
Oscar Salvador
SUSE L3
