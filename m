Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5AE48E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 20:10:20 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c8-v6so3403326plz.0
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:10:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d2-v6si5049021pgp.256.2018.09.13.17.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 17:10:19 -0700 (PDT)
Date: Thu, 13 Sep 2018 17:10:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 0/6] VA to numa node information
Message-Id: <20180913171016.55dca2453c0773fc21044972@linux-foundation.org>
In-Reply-To: <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
	<20180913084011.GC20287@dhcp22.suse.cz>
	<375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: prakash.sangappa@oracle.com
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com

On Thu, 13 Sep 2018 15:32:25 -0700 "prakash.sangappa" <prakash.sangappa@oracle.com> wrote:

> >> https://marc.info/?t=152524073400001&r=1&w=2
> > It would be really great to give a short summary of the previous
> > discussion. E.g. why do we need a proc interface in the first place when
> > we already have an API to query for the information you are proposing to
> > export [1]
> >
> > [1] http://lkml.kernel.org/r/20180503085741.GD4535@dhcp22.suse.cz
> 
> The proc interface provides an efficient way to export address range
> to numa node id mapping information compared to using the API.
> For example, for sparsely populated mappings, if a VMA has large portions
> not have any physical pages mapped, the page walk done thru the /proc file
> interface can skip over non existent PMDs / ptes. Whereas using the
> API the application would have to scan the entire VMA in page size units.
> 
> Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
> The page walks would be efficient in scanning and determining if it is
> a THP huge page and step over it. Whereas using the API, the application
> would not know what page size mapping is used for a given VA and so would
> have to again scan the VMA in units of 4k page size.
> 
> If this sounds reasonable, I can add it to the commit / patch description.

Preferably with some runtime measurements, please.  How much faster is
this interface in real-world situations?  And why does that performance
matter?

It would also be useful to see more details on how this info helps
operators understand/tune/etc their applications and workloads.  In
other words, I'm trying to get an understanding of how useful this code
might be to our users in general.
