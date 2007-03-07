Message-ID: <45EF22CF.9030205@debian.org>
Date: Wed, 07 Mar 2007 15:38:39 -0500
From: Andres Salomon <dilinger@debian.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't use ZONE_DMA unless CONFIG_ZONE_DMA is set
 in setup.c
References: <45EDFEDB.3000507@debian.org> <20070306175246.b1253ec3.akpm@linux-foundation.org> <20070307040248.GA30278@redhat.com> <45EE42BC.6030209@debian.org> <Pine.LNX.4.64.0703071224470.24546@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703071224470.24546@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 6 Mar 2007, Andres Salomon wrote:
> 
>> It would've been nice to see the ZONE_DMA removal patches just #define
>> ZONE_DMA regardless, and include less #ifdefs scattered about; but at
>> this point, I'd just as soon prefer to see a proper way to allocate
>> things based on address constraints (as discussed in
>> http://www.gelato.unsw.edu.au/archives/linux-ia64/0609/19036.html).
> 
> Would you be willing to work on that? I can sent you a bunch of unfinished 
> patches if you have the time.

Sure, I'd be willing to work on it.  Whether or not I have the time is
questionable, but it wouldn't hurt to send them..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
