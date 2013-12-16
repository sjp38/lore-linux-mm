Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id B01126B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 14:27:06 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so2447572eek.10
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 11:27:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w6si15167138eeg.90.2013.12.16.11.27.05
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 11:27:06 -0800 (PST)
Message-ID: <52AF5400.5080400@redhat.com>
Date: Mon, 16 Dec 2013 14:26:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mm: page_alloc: Default allow file pages to use remote
 nodes for fair allocation policy
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> Indications from Johannes that he wanted this. Needs some data and/or justification why
> thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
> it should be considered finished. I do not necessarily agree this patch is necessary
> but it's worth punting it out there for discussion and testing.

This seems like a sane default to me.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
