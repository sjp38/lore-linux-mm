Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D23D8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:50:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so8895948edc.9
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:50:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u12si252195edd.379.2018.12.17.05.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:50:37 -0800 (PST)
Subject: Re: [PATCH 03/14] mm, compaction: Remove last_migrated_pfn from
 compact_control
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <76f7182b-5521-2ee9-fa6f-4331e1eae313@suse.cz>
Date: Mon, 17 Dec 2018 14:50:35 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:02 AM, Mel Gorman wrote:
> The last_migrated_pfn field is a bit dubious as to whether it really helps
> but either way, the information from it can be inferred without increasing
> the size of compact_control so remove the field.

Yeah looks like this won't cause more frequent drains.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
