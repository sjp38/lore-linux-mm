Date: Mon, 14 Oct 2002 18:40:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Lse-tech] Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <20021015014023.GO4488@holomorphy.com>
References: <20021015012015.GN4488@holomorphy.com> <2008756258.1034620187@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2008756258.1034620187@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: john stultz <johnstul@us.ibm.com>, Matt <colpatch@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE Tech <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> I thought zholes stuff freed the struct pages. Maybe that was done
>> by hand.

On Mon, Oct 14, 2002 at 06:29:49PM -0700, Martin J. Bligh wrote:
> The only place I see that used in generic code is
> calculate_zone_totalpages, free_area_init_core, free_area_init_node,
> none of which seem to do that. But cscope might be borked again, I
> guess. Must be done in each arch if at all ... which arch did you
> think did it?

Not sure, ISTR something about this going on but I don't see any extant
examples. At any rate, it should be easy to do it by hand, just make
sure there are struct pages tracking the holes in mem_map and free the
space in mem_map that would track the holes.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
