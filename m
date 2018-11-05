Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3EA6B027E
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:44:05 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id j9-v6so10702322pfn.20
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:44:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q132-v6si30668449pfc.198.2018.11.05.13.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:44:03 -0800 (PST)
Date: Mon, 5 Nov 2018 13:44:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-Id: <20181105134400.f6f52f4db0f8d6a21446476e@linux-foundation.org>
In-Reply-To: <beaa1acf7423da7ee0f9bbc4cee2d14a@codeaurora.org>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
	<72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
	<efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
	<20181010173334.GL5873@dhcp22.suse.cz>
	<a2d576a5fc82cdf54fc89409686e58f5@codeaurora.org>
	<20181011075503.GQ5873@dhcp22.suse.cz>
	<20181018191825.fcad6e28f32a3686f201acdf@linux-foundation.org>
	<20181019080755.GK18839@dhcp22.suse.cz>
	<c6289fada694462ed708174f9a1f3b6c@codeaurora.org>
	<beaa1acf7423da7ee0f9bbc4cee2d14a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Mon, 05 Nov 2018 15:12:27 +0530 Arun KS <arunks@codeaurora.org> wrote:

> On 2018-10-22 16:03, Arun KS wrote:
> > On 2018-10-19 13:37, Michal Hocko wrote:
> >> On Thu 18-10-18 19:18:25, Andrew Morton wrote:
> >> [...]
> >>> So this patch needs more work, yes?
> >> 
> >> Yes, I've talked to Arun (he is offline until next week) offlist and 
> >> he
> >> will play with this some more.
> > 
> > Converted totalhigh_pages, totalram_pages and zone->managed_page to
> > atomic and tested hot add. Latency is not effected with this change.
> > Will send out a separate patch on top of this one.
> Hello Andrew/Michal,
> 
> Will this be going in subsequent -rcs?

I thought were awaiting a new version?  "Will send out a separate patch
on top of this one"?

I do think a resend would be useful, please.  Ensure the changelog is
updated to capture the above info and any other worthy issues which
arose during review.
