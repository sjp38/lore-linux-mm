Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3835A6B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:35:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w11-v6so10972215pfk.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:35:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e7-v6si20333247plt.325.2018.07.11.14.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:35:07 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:35:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm, page_alloc: double zone's batchsize
Message-Id: <20180711143505.5ccb378fb67dc6ba8fa202a3@linux-foundation.org>
In-Reply-To: <20180711055855.29072-1-aaron.lu@intel.com>
References: <20180711055855.29072-1-aaron.lu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

On Wed, 11 Jul 2018 13:58:55 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> [550 lines of changelog]

OK, I'm convinced ;)  That was a lot of work - thanks for being exhaustive.

Of course, not all the world is x86 but I think we can be confident
that other architectures are unlikely to be harmed by the change, at least.
