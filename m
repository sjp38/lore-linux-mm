Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC5168E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 13:14:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z30-v6so9648073edd.19
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:14:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j13-v6si13930444edk.46.2018.09.24.10.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 10:14:45 -0700 (PDT)
Date: Mon, 24 Sep 2018 19:14:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 0/6] VA to numa node information
Message-ID: <20180924171443.GI18685@dhcp22.suse.cz>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Sistare <steven.sistare@oracle.com>
Cc: "prakash.sangappa" <prakash.sangappa@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

On Fri 14-09-18 12:01:18, Steven Sistare wrote:
> On 9/14/2018 1:56 AM, Michal Hocko wrote:
[...]
> > Why does this matter for something that is for analysis purposes.
> > Reading the file for the whole address space is far from a free
> > operation. Is the page walk optimization really essential for usability?
> > Moreover what prevents move_pages implementation to be clever for the
> > page walk itself? In other words why would we want to add a new API
> > rather than make the existing one faster for everybody.
> 
> One could optimize move pages.  If the caller passes a consecutive range
> of small pages, and the page walk sees that a VA is mapped by a huge page, 
> then it can return the same numa node for each of the following VA's that fall 
> into the huge page range. It would be faster than 55 nsec per small page, but 
> hard to say how much faster, and the cost is still driven by the number of 
> small pages. 

This is exactly what I was arguing for. There is some room for
improvements for the existing interface. I yet have to hear the explicit
usecase which would required even better performance that cannot be
achieved by the existing API.

-- 
Michal Hocko
SUSE Labs
