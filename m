Date: Wed, 31 Jul 2002 16:23:57 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: throttling dirtiers
Message-ID: <20020731162357.Q10270@redhat.com>
References: <3D479F21.F08C406C@zip.com.au> <20020731200612.GJ29537@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020731200612.GJ29537@holomorphy.com>; from wli@holomorphy.com on Wed, Jul 31, 2002 at 01:06:12PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2002 at 01:06:12PM -0700, William Lee Irwin III wrote:
> I'm not a fan of this kind of global decision. For example, I/O devices
> may be fast enough and memory small enough to dump all memory in < 1s,
> in which case dirtying most or all of memory is okay from a latency
> standpoint, or it may take hours to finish dumping out 40% of memory,
> in which case it should be far more eager about writeback.

Why?  Filling the entire ram with dirty pages is okay, and in fact you 
want to support that behaviour for apps that "just fit" (think big 
scientific apps).  The only interesting point is that when you hit the 
limit of available memory, the system needs to block on *any* io 
completing and resulting in clean memory (which is reasonably low 
latency), not a specific io which may have very high latency.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
