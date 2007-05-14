Date: Tue, 15 May 2007 00:45:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 02/41] Revert 81b0c8713385ce1b1b9058e916edcf9561ad76d6
Message-ID: <20070514224523.GF5531@wotan.suse.de>
References: <20070514060619.689648000@wotan.suse.de> <20070514060650.231658000@wotan.suse.de> <20070514190635.GC29024@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070514190635.GC29024@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 14, 2007 at 03:06:35PM -0400, Dave Jones wrote:
> On Mon, May 14, 2007 at 04:06:21PM +1000, npiggin@suse.de wrote:
>  > This was a bugfix against 6527c2bdf1f833cc18e8f42bd97973d583e4aa83, which we
>  > also revert.
> 
> changes like this play havoc with git-bisect.  If you must revert stuff
> before patching new code in, revert it all in a single diff.

It's all going to still boot and run...

But I guess there is no harm in merging them, however I'll send them
to Andrew singularly and he can merge them if he likes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
