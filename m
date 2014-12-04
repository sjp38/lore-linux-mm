Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 10B406B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 06:15:54 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so27492406wiw.16
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 03:15:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si45263197wiy.107.2014.12.04.03.15.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 03:15:53 -0800 (PST)
Date: Thu, 4 Dec 2014 11:15:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
Message-ID: <20141204111546.GK6043@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
 <1416578268-19597-4-git-send-email-mgorman@suse.de>
 <1417473762.7182.8.camel@kernel.crashing.org>
 <87k32ah5q3.fsf@linux.vnet.ibm.com>
 <1417551115.27448.7.camel@kernel.crashing.org>
 <87lhmobvuu.fsf@linux.vnet.ibm.com>
 <20141203155242.GE6043@suse.de>
 <1417640517.4741.14.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1417640517.4741.14.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Dec 04, 2014 at 08:01:57AM +1100, Benjamin Herrenschmidt wrote:
> On Wed, 2014-12-03 at 15:52 +0000, Mel Gorman wrote:
> > 
> > It's implied but can I assume it passed? If so, Ben and Paul, can I
> > consider the series to be acked by you other than the minor comment
> > updates?
> 
> Yes. Assuming it passed :-)
> 
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 

Sweet, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
