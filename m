Subject: Re: 2.5.65-mm1
References: <20030318031104.13fb34cc.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 18 Mar 2003 16:08:51 +0100
In-Reply-To: <20030318031104.13fb34cc.akpm@digeo.com>
Message-ID: <87adfs4sqk.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:
>
> [SNIP]
>

I tried to get find what made 2.5.64-mm1 special that made my Radeon
card work, and had no luck in boiling down the differences more than
generally waving in the general direction "seems to be the PCI
updates". Nothing, up to and including 2.5.64-mm8, worked, but now
2.5.65-mm1 works like a charm and I'm on it now. I'll let you know if
it breaks again (or other breakage I find) :)

mvh,
A
-- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
