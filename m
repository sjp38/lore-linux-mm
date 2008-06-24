Date: Tue, 24 Jun 2008 10:01:54 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [rfc patch 2/4] splice: remove steal from pipe_buf_operations
Message-ID: <20080624080152.GI20851@kernel.dk>
References: <20080621154607.154640724@szeredi.hu> <20080621154724.203822363@szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080621154724.203822363@szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 21 2008, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> The 'steal' operation hasn't been used for some time.  Remove it and
> the associated dead code.  If it's needed in the future, it can always
> be easily restored.

I'd rather not just remove this, it's basically waiting for Nick to make
good on his promise to make stealing work again (he disabled it).

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
