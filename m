Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5546B0003
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 04:16:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y23-v6so3471211eds.12
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 01:16:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f27-v6si4333563ede.346.2018.11.04.01.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 01:16:23 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA498jWi030516
	for <linux-mm@kvack.org>; Sun, 4 Nov 2018 04:16:21 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nhrvdgbe0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 04 Nov 2018 04:16:21 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 4 Nov 2018 09:16:19 -0000
Date: Sun, 4 Nov 2018 11:16:12 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102160122.GH194472@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102160122.GH194472@sasha-vm>
Message-Id: <20181104091611.GC7829@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Dexuan Cui <decui@microsoft.com>, Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 12:01:22PM -0400, Sasha Levin wrote:
> On Fri, Nov 02, 2018 at 02:45:42AM +0000, Dexuan Cui wrote:
> >>From: Roman Gushchin <guro@fb.com>
> >>Sent: Thursday, November 1, 2018 17:58
> >>
> >>On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
> >>Hello, Dexuan!
> >>
> >>A couple of issues has been revealed recently, here are fixes
> >>(hashes are from the next tree):
> >>
> >>5f4b04528b5f mm: don't reclaim inodes with many attached pages
> >>5a03b371ad6a mm: handle no memcg case in memcg_kmem_charge()
> >>properly
> >>
> >>These two patches should be added to the serie.
> >
> >Thanks for the new info!
> >
> >>Re stable backporting, I'd really wait for some time. Memory reclaim is a
> >>quite complex and fragile area, so even if patches are correct by themselves,
> >>they can easily cause a regression by revealing some other issues (as it was
> >>with the inode reclaim case).
> >
> >I totally agree. I'm now just wondering if there is any temporary workaround,
> >even if that means we have to run the kernel with some features disabled or
> >with a suboptimal performance?
> 
> I'm not sure what workload you're seeing it on, but if you could merge
> these 7 patches and see that it solves the problem you're seeing and
> doesn't cause any regressions it'll be a useful test for the rest of us.

AFAIK, with Roman's patches backported to Ubuntu version of 4.15, the
problem reported at [1] is solved.

[1] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1792349
 
> --
> Thanks,
> Sasha
> 

-- 
Sincerely yours,
Mike.
