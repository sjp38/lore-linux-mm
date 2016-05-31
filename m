From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: The patch "mm, page_alloc: avoid looking up the first zone in a
 zonelist twice" breaks memory management
Date: Tue, 31 May 2016 23:47:51 +0200
Message-ID: <574E0687.5050201@suse.cz>
References: <alpine.LRH.2.02.1605311706040.16635@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1605311706040.16635@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Helge Deller <deller@gmx.de>
List-Id: linux-mm.kvack.org

On 05/31/2016 11:20 PM, Mikulas Patocka wrote:
> Hi
> 
> The patch c33d6c06f60f710f0305ae792773e1c2560e1e51 ("mm, page_alloc: avoid 
> looking up the first zone in a zonelist twice") breaks memory management 
> on PA-RISC.

Hi,

I think the linked patch should help. Please try and report.

http://marc.info/?i=20160531100848.GR2527%40techsingularity.net

Thanks,
Vlastimil
