From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Date: Mon, 16 Jan 2017 11:13:10 +0100
Message-ID: <20170116101310.4n5qof3skqpoyvup@pd.tnic>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
 <20170116094851.GD32481@mtr-leonro.local>
 <20170116095522.lrqcoqktozvoeaql@pd.tnic>
 <20170116100930.GE32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170116100930.GE32481@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jan 16, 2017 at 12:09:30PM +0200, Leon Romanovsky wrote:
> And doesn't dump_stack do the same? It pollutes the log too.

It is not about polluting the log - it is about tainting.

__warn()->add_taint(taint, LOCKDEP_STILL_OK);

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
