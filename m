Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 089E86B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:00:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j8-v6so1102646wrh.18
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:00:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n192-v6si50901wmg.186.2018.06.27.05.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:00:30 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RBsCgU033967
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:00:29 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jv9h19t9b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:00:28 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 13:00:26 +0100
Date: Wed, 27 Jun 2018 15:00:20 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] alpha: switch to NO_BOOTMEM
References: <1530099168-31421-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180627113851.GP32348@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627113851.GP32348@dhcp22.suse.cz>
Message-Id: <20180627120020.GE4291@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-alpha <linux-alpha@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2018 at 01:38:51PM +0200, Michal Hocko wrote:
> On Wed 27-06-18 14:32:48, Mike Rapoport wrote:
> > Replace bootmem allocator with memblock and enable use of NO_BOOTMEM like
> > on most other architectures.
> > 
> > The conversion does not take care of NUMA support which is marked broken
> > for more than 10 years now.
> 
> It would be great to describe how is the conversion done. At least on
> high level.

It's straightforward, isn't it? :)

Sure, no problem. I'll just wait for other feedback before sending v2.

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
