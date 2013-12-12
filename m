Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3D90E6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 15:11:56 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so774659yha.3
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:11:56 -0800 (PST)
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
        by mx.google.com with ESMTPS id x8si8726474qch.54.2013.12.12.12.11.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 12:11:55 -0800 (PST)
Received: by mail-qc0-f181.google.com with SMTP id e9so726959qcy.40
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:11:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131212180050.GC134240@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com> <20131212180050.GC134240@sgi.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 12 Dec 2013 12:11:34 -0800
Message-ID: <CALCETrWfFRhjuoK8T9G8hecxsRxFPQ+qA0x7azoof1X5tuxruA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] Add tunable to control THP behavior
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 12, 2013 at 10:00 AM, Alex Thorlton <athorlton@sgi.com> wrote:
> This part of the patch adds a tunable to
> /sys/kernel/mm/transparent_hugepage called threshold.  This threshold
> determines how many pages a user must fault in from a single node before
> a temporary compound page is turned into a THP.

Is there a setting that will turn off the must-be-the-same-node
behavior?  There are workloads where TLB matters more than cross-node
traffic (or where all the pages are hopelessly shared between nodes,
but hugepages are still useful).

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
