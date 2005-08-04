Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j74MigSZ535672
	for <linux-mm@kvack.org>; Thu, 4 Aug 2005 18:44:42 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j74Mio5q192278
	for <linux-mm@kvack.org>; Thu, 4 Aug 2005 16:44:50 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j74MifNq030302
	for <linux-mm@kvack.org>; Thu, 4 Aug 2005 16:44:41 -0600
Date: Thu, 4 Aug 2005 15:44:39 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: NUMA policy interface
Message-ID: <20050804224439.GC3933@w-mikek2.ibm.com>
References: <20050803084849.GB10895@wotan.suse.de> <Pine.LNX.4.62.0508040704590.3319@graphe.net> <20050804142942.GY8266@wotan.suse.de> <Pine.LNX.4.62.0508040922110.6650@graphe.net> <20050804170803.GB8266@wotan.suse.de> <Pine.LNX.4.62.0508041011590.7314@graphe.net> <20050804211445.GE8266@wotan.suse.de> <Pine.LNX.4.62.0508041416490.10150@graphe.net> <20050804214132.GF8266@wotan.suse.de> <Pine.LNX.4.62.0508041509330.10813@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0508041509330.10813@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 04, 2005 at 03:19:52PM -0700, Christoph Lameter wrote:
> This code already exist in the memory hotplug code base and Ray already 
> had a working implementation for page migration. The migration code will 
> also be necessary in order to relocate pages with ECC single bit failures 
> that Russ is working on (of course that will only work for some pages) and
> for Mel Gorman's defragmentation approach (if we ever get the split into 
> differnet types of memory chunks in).

Yup, we need page migration for memory hotplug.  However, for hotplug
we are not too concerned about where the pages are migrated to.  Our
primary concern is to move them out of the block/section that we want
to offline.  Suspect this is the same for pages with ECC single bit
failures.  In fact, this is one possible use of the hotplug code.
Notice a failure.  Migrate all pages off the containing DIMM.  Offline
section corresponding to DIMM.  Replace the DIMM.  Online section
corresponding to DIMM.  Of course, your hardware needs to be able to
do this.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
