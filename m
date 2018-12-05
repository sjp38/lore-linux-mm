Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 063EF6B763C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:42:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so7981856edb.8
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 12:42:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l16-v6si1330251ejs.186.2018.12.05.12.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 12:42:49 -0800 (PST)
Date: Wed, 5 Dec 2018 21:42:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to set_page_links
Message-ID: <20181205204247.GY1286@dhcp22.suse.cz>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
 <154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
 <20181205172225.GT1286@dhcp22.suse.cz>
 <19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Wed 05-12-18 09:55:17, Alexander Duyck wrote:
> On Wed, 2018-12-05 at 18:22 +0100, Michal Hocko wrote:
> > On Fri 30-11-18 13:53:18, Alexander Duyck wrote:
> > > Modify the set_page_links function to include the setting of the reserved
> > > flag via a simple AND and OR operation. The motivation for this is the fact
> > > that the existing __set_bit call still seems to have effects on performance
> > > as replacing the call with the AND and OR can reduce initialization time.
> > > 
> > > Looking over the assembly code before and after the change the main
> > > difference between the two is that the reserved bit is stored in a value
> > > that is generated outside of the main initialization loop and is then
> > > written with the other flags field values in one write to the page->flags
> > > value. Previously the generated value was written and then then a btsq
> > > instruction was issued.
> > > 
> > > On my x86_64 test system with 3TB of persistent memory per node I saw the
> > > persistent memory initialization time on average drop from 23.49s to
> > > 19.12s per node.
> > 
> > I have tried to explain why the whole reserved bit doesn't make much
> > sense in this code several times already. You keep ignoring that and
> > that is highly annoying. Especially when you add a tricky code to
> > optimize something that is not really needed.
> > 
> > Based on that I am not going to waste my time on other patches in this
> > series to review and give feedback which might be ignored again.
> 
> I got your explanation. However Andrew had already applied the patches
> and I had some outstanding issues in them that needed to be addressed.
> So I thought it best to send out this set of patches with those fixes
> before the code in mm became too stale. I am still working on what to
> do about the Reserved bit, and plan to submit it as a follow-up set.

>From my experience Andrew can drop patches between different versions of
the patchset. Things can change a lot while they are in mmotm and under
the discussion.
-- 
Michal Hocko
SUSE Labs
