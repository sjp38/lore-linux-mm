Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5EDA6B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:36:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c2-v6so5389036edi.20
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:36:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x21-v6si742201edq.436.2018.08.07.06.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 06:36:05 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w77DSvA4095959
	for <linux-mm@kvack.org>; Tue, 7 Aug 2018 09:36:03 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kqbqe28s0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:36:02 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 7 Aug 2018 14:36:00 +0100
Date: Tue, 7 Aug 2018 16:35:52 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
 <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
 <20180807110951.GZ10003@dhcp22.suse.cz>
 <20180807111926.ibdkzgghn3nfugn2@breakpoint.cc>
 <20180807112641.GB10003@dhcp22.suse.cz>
 <6a9460c1-cb63-27e1-dd29-da3f736cfa09@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a9460c1-cb63-27e1-dd29-da3f736cfa09@suse.cz>
Message-Id: <20180807133551.GG20140@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Florian Westphal <fw@strlen.de>, Georgi Nikolov <gnikolov@icdsoft.com>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Tue, Aug 07, 2018 at 01:31:21PM +0200, Vlastimil Babka wrote:
> On 08/07/2018 01:26 PM, Michal Hocko wrote:
> > On Tue 07-08-18 13:19:26, Florian Westphal wrote:
> >> Michal Hocko <mhocko@kernel.org> wrote:
> >>>> I can't reproduce it anymore.
> >>>> If i understand correctly this way memory allocated will be
> >>>> accounted to kmem of this cgroup (if inside cgroup).
> >>>
> >>> s@this@caller's@
> >>>
> >>> Florian, is this patch acceptable
> >>
> >> I am no mm expert.  Should all longlived GFP_KERNEL allocations set ACCOUNT?
> > 
> > No. We should focus only on those that are under direct userspace
> > control and it can be triggered by an untrusted user.
> 
> Looks like the description in include/linux/gfp.h could use some details
> to guide developers, possibly also Mike's new/improved docs (+CC).

A "memory allocation guide" is definitely on my todo.

If you and other mm developers have any notes, random thoughts or anything else you'd
like to see there, send it my way, I'll convert them to ReST :-).

> >> If so, there are more places that should get same treatment.
> >> The change looks fine to me, but again, I don't know when ACCOUNT should
> >> be set in the first place.
> > 
> > see above.
> > 
> 

-- 
Sincerely yours,
Mike.
