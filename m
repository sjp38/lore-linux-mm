From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Date: Mon, 16 Jan 2017 10:55:22 +0100
Message-ID: <20170116095522.lrqcoqktozvoeaql@pd.tnic>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
 <20170116094851.GD32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170116094851.GD32481@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jan 16, 2017 at 11:48:51AM +0200, Leon Romanovsky wrote:
> Almost, except one point - pr_warn and dump_stack have different log

Actually, Michal pointed out on IRC a more relevant difference:

WARN() taints the kernel and we don't want that for GFP flags misuse.
Also, from looking at __warn(), it checks panic_on_warn and we explode
if set.

So no, we probably don't want WARN() here.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
