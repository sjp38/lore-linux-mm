Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8931E6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:32:48 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so66421378pdb.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:32:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ps1si8800711pbb.236.2015.04.15.14.32.47
        for <linux-mm@kvack.org>;
        Wed, 15 Apr 2015 14:32:47 -0700 (PDT)
Message-ID: <552ED8FF.8000109@intel.com>
Date: Wed, 15 Apr 2015 14:32:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
References: <1429094576-5877-1-git-send-email-mgorman@suse.de> <1429094576-5877-3-git-send-email-mgorman@suse.de> <552ED214.3050105@redhat.com> <alpine.LSU.2.11.1504151410150.13745@eggly.anvils> <20150415212855.GI14842@suse.de>
In-Reply-To: <20150415212855.GI14842@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2015 02:28 PM, Mel Gorman wrote:
> This is what I'm expecting i.e. clean->dirty transition is write-through
> to the PTE which is now unmapped and it traps. I'm assuming there is an
> architectural guarantee that it happens but could not find an explicit
> statement in the docs. I'm hoping Dave or Andi can check with the relevant
> people on my behalf.

The docs do look a bit ambiguous to me.  I'm working on getting some
clarified language in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
