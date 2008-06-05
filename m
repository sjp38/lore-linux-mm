Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m55NFMAT032242
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 19:15:22 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m55NFLJ6098898
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 17:15:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m55NFK0r022033
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 17:15:21 -0600
Date: Thu, 5 Jun 2008 17:15:19 -0600
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080605231519.GD31534@us.ibm.com>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net> <20080603205752.GK20824@one.firstfloor.org> <1212528479.7567.28.camel@nimitz.home.sr71.net> <4845DC72.5080206@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4845DC72.5080206@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 04.06.2008 [02:06:10 +0200], Andi Kleen wrote:
> 
> > Also, as I said, users doesn't really know what the OS or hardware will
> > support 
> 
> The normal Linux expectation is that these kinds of users will not
> use huge pages at all.  Or rather if everybody was supposed to use
> them then all the interfaces would need to be greatly improved and any
> kinds of boot parameters would be out and they would need to be
> 100% integrated with the standard VM.
> 
> Hugepages are strictly an harder-to-use optimization for specific people
> who love to tweak (e.g. database administrators or benchmarkers). From
> what I heard so far these people like to have more control, not less.

I really don't want to get involved in this discussion, but let me just
say: "Hugepages are *right now* strictly a harder-to-use optimization".
libhugetlbfs helps quite a bit (in my opinion) as far as making
hugepages easier to use. And Adam's dynamic pool work does as well. It's
progress, slow and steady as it may be. I don't really appreciate the
entire hugepage area being pigeon-holed into what you've experienced.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
