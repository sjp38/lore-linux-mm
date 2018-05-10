Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3DFE6B05C9
	for <linux-mm@kvack.org>; Thu, 10 May 2018 03:43:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j14-v6so740149pfn.11
        for <linux-mm@kvack.org>; Thu, 10 May 2018 00:43:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10-v6si215863plh.378.2018.05.10.00.42.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 00:42:58 -0700 (PDT)
Date: Thu, 10 May 2018 09:42:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
Message-ID: <20180510074254.GE32366@dhcp22.suse.cz>
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
 <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
 <20180504111211.GO4535@dhcp22.suse.cz>
 <de18dc06-6448-d6e5-fa80-c6065edd3aa4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <de18dc06-6448-d6e5-fa80-c6065edd3aa4@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: Christopher Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com

On Fri 04-05-18 09:18:11, Prakash Sangappa wrote:
> 
> 
> On 5/4/18 4:12 AM, Michal Hocko wrote:
> > On Thu 03-05-18 15:39:49, prakash.sangappa wrote:
> > > 
> > > On 05/03/2018 11:03 AM, Christopher Lameter wrote:
> > > > On Tue, 1 May 2018, Prakash Sangappa wrote:
> > > > 
> > > > > For analysis purpose it is useful to have numa node information
> > > > > corresponding mapped address ranges of the process. Currently
> > > > > /proc/<pid>/numa_maps provides list of numa nodes from where pages are
> > > > > allocated per VMA of the process. This is not useful if an user needs to
> > > > > determine which numa node the mapped pages are allocated from for a
> > > > > particular address range. It would have helped if the numa node information
> > > > > presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
> > > > > exact numa node from where the pages have been allocated.
> > > > Cant you write a small script that scans the information in numa_maps and
> > > > then displays the total pages per NUMA node and then a list of which
> > > > ranges have how many pages on a particular node?
> > > Don't think we can determine which numa node a given user process
> > > address range has pages from, based on the existing 'numa_maps' file.
> > yes we have. See move_pages...
> 
> Sure using move_pages, not based on just 'numa_maps'.
> 
> > > > > reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
> > > > So a prime motivator here is security restricted access to numa_maps?
> > > No it is the opposite. A regular user should be able to determine
> > > numa node information.
> > Well, that breaks the layout randomization, doesn't it?
> 
> Exposing numa node information itself should not break randomization right?

I thought you planned to expose address ranges for each numa node as
well. /me confused.

> It would be upto the application. In case of randomization, the application
> could generate  address range traces of interest for debugging and then
> using numa node information one could determine where the memory is laid
> out for analysis.

... even more confused

-- 
Michal Hocko
SUSE Labs
