Date: Wed, 14 Feb 2007 05:28:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: NUMA replicated pagecache
Message-ID: <20070214042843.GD7125@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070213060924.GB20644@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 13, 2007 at 07:09:24AM +0100, Nick Piggin wrote:
> 
> Issues:
> - Not commented. I want to change the interfaces around anyway.
> - Breaks filesystems that use filemap_nopage, but don't call filemap_mkwrite
>   (eg. XFS). Fix is trivial for most cases.
> - Haven't tested NUMA yet (only tested via a hack to do per-CPU replication)
> - Would like to be able to control replication via userspace, and maybe
>   even internally to the kernel.
> - Ideally, reclaim might reclaim replicated pages preferentially, however
>   I aim to be _minimally_ intrusive.
> - Would like to replicate PagePrivate, but filesystem may dirty page via
>   buffers. Any solutions? (currently should mount with 'nobh').

Hmm, I guess we should be able to do this for pagecache of regular files,
as filesystems should not have any business dirtying that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
