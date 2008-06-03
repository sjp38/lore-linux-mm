Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m53J1M1U017940
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 15:01:22 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m53J1F8P1286230
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 15:01:15 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m53J0rBI012770
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 13:00:54 -0600
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080603182413.GJ20824@one.firstfloor.org>
References: <20080603095956.781009952@amd.local0.net>
	 <20080603100939.967775671@amd.local0.net>
	 <1212515282.8505.19.camel@nimitz.home.sr71.net>
	 <20080603182413.GJ20824@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 12:00:51 -0700
Message-Id: <1212519651.8505.36.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 20:24 +0200, Andi Kleen wrote:
> On Tue, Jun 03, 2008 at 10:48:02AM -0700, Dave Hansen wrote:
> > First of all, it seems a bit silly to require that users spell out all
> > of the huge page sizes at boot.  Shouldn't we allow the small sizes to
> > be runtime-added as well
> 
> They are already for most systems where you have only two
> hpage sizes. That is because the legacy hpage size is always 
> added and you can still allocate pages for it using the sysctl. And if
> you want to prereserve at boot you'll have to spell the size out
> explicitely anyways.

Yeah, it doesn't make much sense if you're looking at x86 with 2/4MB and
1GB.  But, for ppc or ia64, you might have actual chances at runtime to
allocate huge pages, even for non-default sizes.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
