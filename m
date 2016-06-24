Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D12286B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 07:51:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a2so73829556lfe.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 04:51:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qd5si6636780wjb.196.2016.06.24.04.51.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 04:51:40 -0700 (PDT)
Subject: Re: [PATCH v3 07/17] mm, compaction: introduce direct compaction
 priority
References: <201606241959.RM8ORGlk%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <95450d73-7108-ffd8-07c4-95abf9d5f34f@suse.cz>
Date: Fri, 24 Jun 2016 13:51:37 +0200
MIME-Version: 1.0
In-Reply-To: <201606241959.RM8ORGlk%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 06/24/2016 01:39 PM, kbuild test robot wrote:
> Hi,
> 
> [auto build test ERROR on next-20160624]
> [cannot apply to tip/perf/core v4.7-rc4 v4.7-rc3 v4.7-rc2 v4.7-rc4]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

Hmm, rebasing snafu. Here's updated patch:

----8<----
