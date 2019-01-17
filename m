Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBF78E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:27:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so3987599edd.2
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:27:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si6208223eda.224.2019.01.17.09.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:27:17 -0800 (PST)
Subject: Re: [PATCH 18/25] mm, compaction: Rework compact_should_abort as
 compact_check_resched
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-19-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b3fed67a-30f4-9ff6-769d-deff2d141465@suse.cz>
Date: Thu, 17 Jan 2019 18:27:15 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-19-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> With incremental changes, compact_should_abort no longer makes
> any documented sense. Rename to compact_check_resched and update the
> associated comments.  There is no benefit other than reducing redundant
> code and making the intent slightly clearer. It could potentially be
> merged with earlier patches but it just makes the review slightly
> harder.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
