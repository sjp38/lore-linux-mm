Date: Wed, 30 Apr 2008 20:42:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 4/4] mm: Unexport __alloc_bootmem_core()
Message-ID: <20080430184235.GD3008@elte.hu>
References: <20080430170521.246745395@symbol.fehenstaub.lan> <20080430170840.176104554@symbol.fehenstaub.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430170840.176104554@symbol.fehenstaub.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Johannes Weiner <hannes@saeurebad.de> wrote:

> This function has no external callers, so unexport it.  Also fix its
> naming inconsistency.
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> CC: Ingo Molnar <mingo@elte.hu>
> ---
> 
> It could be argued that all bootmem alloc function names begin with 
> underscores.  But I chose to `no _core function names begin with 
> underscores' :)

lol :) The double underscores definitely prove it that this code was 
originally written by me ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
