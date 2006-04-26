Date: Wed, 26 Apr 2006 21:21:07 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060426192106.GB9211@suse.de>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <20060426182323.GI5002@suse.de> <20060426114649.5a0e0dea.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060426114649.5a0e0dea.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 26 2006, Andrew Morton wrote:
> Jens Axboe <axboe@suse.de> wrote:
> >
> > Are there cases where the lockless page cache performs worse than the
> > current one?
> 
> Yeah - when human beings try to understand and maintain it.
> 
> The usual tradeoffs apply ;)

Ah ok, thanks for clearing that up :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
