Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 673ED6B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 20:48:42 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 12 Dec 2012 18:48:41 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5EA901FF0039
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:48:32 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBD1mcZw279818
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:48:38 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBD1mbIh024460
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:48:38 -0700
Message-ID: <50C933E9.2040707@linux.vnet.ibm.com>
Date: Wed, 12 Dec 2012 17:48:25 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net> <20121207155125.d3117244.akpm@linux-foundation.org> <50C28720.3070205@linux.vnet.ibm.com> <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/12/2012 05:18 PM, Davidlohr Bueso wrote:
> On Fri, 2012-12-07 at 16:17 -0800, Dave Hansen wrote:
>> Seems like the better way to do this would be to expose the DIMMs
>> themselves in some way, and then map _those_ back to a node.
> 
> Good point, and from a DIMM perspective, I agree, and will look into
> this. However, IMHO, having the range of physical addresses for every
> node still provides valuable information, from a NUMA point of view. For
> example, dealing with node related e820 mappings.

But if we went and did it per-DIMM (showing which physical addresses and
NUMA nodes a DIMM maps to), wouldn't that be redundant with this
proposed interface?

How do you plan to use this in practice, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
