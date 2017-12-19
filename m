Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF9F46B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:05:53 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id c33so2403515itf.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:05:53 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id n14si8372397iod.231.2017.12.19.08.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 08:05:50 -0800 (PST)
Date: Tue, 19 Dec 2017 10:05:48 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/5] mm: Extends local cpu counter vm_diff_nodestat
 from s8 to s16
In-Reply-To: <1513665566-4465-3-git-send-email-kemi.wang@intel.com>
Message-ID: <alpine.DEB.2.20.1712191004420.17324@nuc-kabylake>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com> <1513665566-4465-3-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, 19 Dec 2017, Kemi Wang wrote:

> The type s8 used for vm_diff_nodestat[] as local cpu counters has the
> limitation of global counters update frequency, especially for those
> monotone increasing type of counters like NUMA counters with more and more
> cpus/nodes. This patch extends the type of vm_diff_nodestat from s8 to s16
> without any functionality change.

Well the reason for s8 was to keep the data structures small so that they
fit in the higher level cpu caches. The large these structures become the
more cachelines are used by the counters and the larger the performance
influence on the code that should not be impacted by the overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
