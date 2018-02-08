Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA1166B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 18:36:56 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g16so2906841wmg.6
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 15:36:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l6si726224wrb.94.2018.02.08.15.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 15:36:55 -0800 (PST)
Date: Thu, 8 Feb 2018 15:36:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v1 00/13] lru_lock scalability
Message-Id: <20180208153652.481a77e57cc32c9e1a7e4269@linux-foundation.org>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.m.jordan@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, ak@linux.intel.com, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On Wed, 31 Jan 2018 18:04:00 -0500 daniel.m.jordan@oracle.com wrote:

> lru_lock, a per-node* spinlock that protects an LRU list, is one of the
> hottest locks in the kernel.  On some workloads on large machines, it
> shows up at the top of lock_stat.

Do you have details on which callsites are causing the problem?  That
would permit us to consider other approaches, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
