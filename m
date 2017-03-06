Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 393D56B0390
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 17:11:44 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so146290025pfx.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:11:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b83si10287812pfb.264.2017.03.06.14.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 14:11:43 -0800 (PST)
Date: Mon, 6 Mar 2017 14:11:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, vmstat: suppress pcp stats for unpopulated
 zones in zoneinfo
Message-Id: <20170306141142.f3b22bc0ba43814f546bf3a0@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1703061400500.46428@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com>
	<4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
	<alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1703061400500.46428@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 6 Mar 2017 14:03:32 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> After "mm, vmstat: print non-populated zones in zoneinfo", /proc/zoneinfo 
> will show unpopulated zones.
> 
> The per-cpu pageset statistics are not relevant for unpopulated zones and 
> can be potentially lengthy, so supress them when they are not interesting.
> 
> Also moves lowmem reserve protection information above pcp stats since it 
> is relevant for all zones per vm.lowmem_reserve_ratio.

Well it's not strictly back-compatible, but /proc/zoneinfo is such a
mess that parsers will be few and hopefully smart enough to handle
this.

btw,

  pagesets
    cpu: 0
              count: 118
              high:  186
              batch: 31
  vm stats threshold: 72
    cpu: 1
              count: 53
              high:  186
              batch: 31
  vm stats threshold: 72

Should the "vm stats threshold" thing be indented further?

Do we need to print it out N times anyway?  Can different CPUs have
different values?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
