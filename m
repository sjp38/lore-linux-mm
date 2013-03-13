Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8AD816B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:59:05 -0400 (EDT)
Date: Wed, 13 Mar 2013 09:59:04 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm/hugetlb: fix total hugetlbfs pages count when memory
 overcommit accouting
Message-ID: <20130313165904.GB19692@tassilo.jf.intel.com>
References: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <CAJd=RBBVU8uvHZ3AHkBqOWe-hEqFQ5-5Mf5dGXYuGczvM6EpUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBVU8uvHZ3AHkBqOWe-hEqFQ5-5Mf5dGXYuGczvM6EpUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

> Can we enrich the output of hugetlb_report_meminfo() ?

The data is reported separately in sysfs. It was originally decided
to not extend meminfo for them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
