Date: Thu, 20 Mar 2003 23:15:26 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] anobjrmap 1/6 rmap.h
Message-ID: <20030321071526.GA30140@holomorphy.com>
References: <Pine.LNX.4.44.0303202310440.2743-100000@localhost.localdomain> <20030320224813.0df5a911.akpm@digeo.com> <20030321070746.GF1350@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030321070746.GF1350@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 20, 2003 at 10:48:13PM -0800, Andrew Morton wrote:
>> This all needs to be redone with oprofile, find out what on earth is going
>> on.

On Thu, Mar 20, 2003 at 11:07:46PM -0800, William Lee Irwin III wrote:
> How about this?

These were profiles of kernel compiles on 16x/16GB NUMA-Q.

The profiles leave me more confused than when I started. Cache effects
are potentially responsible.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
