Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4398F6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:11:05 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id g81so17605049ioa.14
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:11:05 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [96.114.154.165])
        by mx.google.com with ESMTPS id d15si3272805iod.223.2017.12.21.09.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 09:11:04 -0800 (PST)
Date: Thu, 21 Dec 2017 11:10:00 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
In-Reply-To: <268b1b6e-ff7a-8f1a-f97c-f94e14591975@intel.com>
Message-ID: <alpine.DEB.2.20.1712211107430.22093@nuc-kabylake>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com> <1513665566-4465-4-git-send-email-kemi.wang@intel.com> <20171219124045.GO2787@dhcp22.suse.cz> <439918f7-e8a3-c007-496c-99535cbc4582@intel.com> <20171220101229.GJ4831@dhcp22.suse.cz>
 <268b1b6e-ff7a-8f1a-f97c-f94e14591975@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 21 Dec 2017, kemi wrote:

> Some thinking about that:
> a) the overhead due to cache bouncing caused by NUMA counter update in fast path
> severely increase with more and more CPUs cores
> b) AFAIK, the typical usage scenario (similar at least)for which this optimization can
> benefit is 10/40G NIC used in high-speed data center network of cloud service providers.

I think you are fighting a lost battle there. As evident from the timing
constraints on packet processing in a 10/40G you will have a hard time to
process data if the packets are of regular ethernet size. And we alrady
have 100G NICs in operation here.

We can try to get the performance as high as possible but full rate high
speed networking invariable must use offload mechanisms and thus the
statistics would only be available from the hardware devices that can do
wire speed processing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
