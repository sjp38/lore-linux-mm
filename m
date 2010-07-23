Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 790346B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 04:14:18 -0400 (EDT)
Date: Fri, 23 Jul 2010 16:14:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100723081414.GA13107@localhost>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
 <20100721160634.GA7976@barrios-desktop>
 <20100722002716.GA7740@sli10-desk.sh.intel.com>
 <AANLkTimDszQHVV8P=C9xjNMY65NDNz16qOm8DUHu=Mz0@mail.gmail.com>
 <20100722051702.GA26829@sli10-desk.sh.intel.com>
 <20100723081224.GB5043@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723081224.GB5043@localhost>
Sender: owner-linux-mm@kvack.org
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 04:12:24PM +0800, Wu Fengguang wrote:
> > Each node has zones, so a pagevec[MAX_NR_ZONES] doesn't work here.
> 
> It's actually pagevec[MAX_NR_ZONES][nr_cpus], where the CPU dimension
> selects a NUMA node. So it looks like a worthy optimization.

Ah sorry, please ignore this. activate_page() may be called from any CPU..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
