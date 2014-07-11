Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9A8900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 04:30:27 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so5859441wib.2
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 01:30:25 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gr5si2538495wib.7.2014.07.11.01.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 01:30:14 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:29:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140711082956.GC20603@laptop.programming.kicks-ass.net>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
> Any comments are welcomed!

Why would anybody _ever_ have a memoryless node? That's ridiculous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
