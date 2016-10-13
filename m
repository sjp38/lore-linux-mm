Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC0966B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:34:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b81so41830915lfe.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:34:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s189si7247973lja.28.2016.10.12.23.34.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 23:34:18 -0700 (PDT)
Date: Thu, 13 Oct 2016 08:34:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM in v4.8
Message-ID: <20161013063416.GD21678@dhcp22.suse.cz>
References: <20161012065423.GA16092@aaronlu.sh.intel.com>
 <20161012074411.GA9523@dhcp22.suse.cz>
 <20161012080022.GA17128@dhcp22.suse.cz>
 <24ea68df-8b6c-5319-a8ef-9c4f237cfc2a@intel.com>
 <519d7220-9750-7be7-436e-407d4dc95d67@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519d7220-9750-7be7-436e-407d4dc95d67@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, lkp@01.org, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 13-10-16 14:23:54, Aaron Lu wrote:
> On 10/12/2016 04:24 PM, Aaron Lu wrote:
> > On 10/12/2016 04:00 PM, Michal Hocko wrote:
[...]
> >> And I am obviously blind because you have already tested with
> >> 101105b1717f which contains the Andrew patchbomb and so all the relevant
> >> changes. Now that I am lookinig into your log for that kernel there
> >> doesn't seem to be any OOM killer invocation. There is only
> >> kern  :warn  : [  177.175954] perf: page allocation failure: order:2, mode:0x208c020(GFP_ATOMIC|__GFP_COMP|__GFP_ZERO)
> > 
> > Oh right, perf may fail but that shouldn't make the test be terminated.
> > I'll need to check why OOM is marked for that test.
> 
> There is a monitor in our test infrastructure that periodically checks
> dmesg for messages like "out of memory", "page allocation failure", etc.
> And if those messages are found, the test is believed not trustworthy
> and killed since most of our tests are performance related.
> 
> That is the reason why "perf page allocation failure" caused the test to
> be marked OOM. I tried to not start perf and with commit 101105b1717f,
> 10 tests finished without any OOM failures.

Thanks for double checking!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
