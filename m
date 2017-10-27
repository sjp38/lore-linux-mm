Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC2B56B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:57:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b192so5071444pga.14
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 00:57:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1si4091101pln.331.2017.10.27.00.57.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 00:57:31 -0700 (PDT)
Date: Fri, 27 Oct 2017 09:57:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
Message-ID: <20171027075727.pc7mj4giv3anewbi@dhcp22.suse.cz>
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
 <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
 <d01827c0-8858-5688-dc16-1e2f597ec55c@linux.vnet.ibm.com>
 <2fc28494-d0d2-9b65-aeb7-1ccabf210917@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2fc28494-d0d2-9b65-aeb7-1ccabf210917@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On Fri 27-10-17 09:36:37, Anshuman Khandual wrote:
> On 10/23/2017 08:52 AM, Anshuman Khandual wrote:
> > On 10/19/2017 09:03 PM, Michal Hocko wrote:
> >> On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
> >>> Its already assumed that the PageActive flag is clear on the input
> >>> page, hence page_lru(page) will pick the base LRU for the page. In
> >>> the same way page_lru(page) will pick active base LRU, once the
> >>> flag PageActive is set on the page. This change of LRU list should
> >>> happen implicitly through the page flags instead of being hard
> >>> coded.
> >>
> >> The patch description tells what but it doesn't explain _why_? Does the
> >> resulting code is better, more optimized or is this a pure readability
> >> thing?
> > 
> > Not really. Not only it removes couple of lines of code but it also
> > makes it look more logical from function flow point of view as well.
> > 
> >>
> >> All I can see is that page_lru is more complex and a large part of it
> >> can be optimized away which has been done manually here. I suspect the
> >> compiler can deduce the same thing.
> > 
> > Why not ? I mean, that is the essence of the function page_lru() which
> > should get us the exact LRU list the page should be on and hence we
> > should not hand craft these manually.
> 
> Hi Michal,
> 
> Did not hear from you on this. So wondering what is the verdict
> about this patch ?

IMHO, there is no reason to change the code as it doesn't solve any real
problem or it doesn't make the code more effective AFAICS.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
