Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 135B16B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 12:57:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i18so25014619wrb.21
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 09:57:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 189si11789499wmy.102.2017.04.03.09.57.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 09:57:09 -0700 (PDT)
Date: Mon, 3 Apr 2017 18:57:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC][LSF/MM,ATTEND] shared TLB, hugetlb reservations
Message-ID: <20170403165706.GR24661@dhcp22.suse.cz>
References: <cad15568-221e-82b7-a387-f23567a0bc76@oracle.com>
 <e09c529d-50e7-e6f2-8054-a34f22b5835a@oracle.com>
 <20170403115137.GB24668@dhcp22.suse.cz>
 <c03e2254-4829-d872-d6f0-ed5d1a22ce89@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c03e2254-4829-d872-d6f0-ed5d1a22ce89@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Mon 03-04-17 09:24:52, Mike Kravetz wrote:
> On 04/03/2017 04:51 AM, Michal Hocko wrote:
> > On Wed 08-03-17 17:30:55, Mike Kravetz wrote:
> >> On 01/10/2017 03:02 PM, Mike Kravetz wrote:
> >>> Another more concrete topic is hugetlb reservations.  Michal Hocko
> >>> proposed the topic "mm patches review bandwidth", and brought up the
> >>> related subject of areas in need of attention from an architectural
> >>> POV.  I suggested that hugetlb reservations was one such area.  I'm
> >>> guessing it was introduced to solve a rather concrete problem.  However,
> >>> over time additional hugetlb functionality was added and the
> >>> capabilities of the reservation code was stretched to accommodate.
> >>> It would be good to step back and take a look at the design of this
> >>> code to determine if a rewrite/redesign is necessary.  Michal suggested
> >>> documenting the current design/code as a first step.  If people think
> >>> this is worth discussion at the summit, I could put together such a
> >>> design before the gathering.
> >>
> >> I attempted to put together a design/overview of how hugetlb reservations
> >> currently work.  Hopefully, this will be useful.
> > 
> > I am still too busy to read through this carefuly and provide a useful
> > feedback but I believe this should go int Documentation/vm/hugetlb$foo
> > file. Care to send it as a patch please?
> 
> Sure
> 
> There is some incomplete information in the document, so I will make
> some revisions and then send out as patch later this week.

Thanks a lot. This is highly appreciated!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
