Date: Tue, 20 Jan 2004 08:37:04 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm5
Message-Id: <20040120083704.482f860c.akpm@osdl.org>
In-Reply-To: <20040120111441.A14570@infradead.org>
References: <20040120000535.7fb8e683.akpm@osdl.org>
	<20040120111441.A14570@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> Any reason you keep CardServices-compatibility-layer.patch around?

err, it's my way of reminding myself that the issue isn't fully resolved. 
Smarter people would use a pencil and a notebook or something.

> Having a compat layer for old driver around just for some architectures,
> thus having drivers that only compile on some for no deeper reasons sounds
> like an incredibly bad idea.  Especially when that API is not used by any
> intree driver and only in -mm ;)

Yes, we were concerned about avoiding breaking the various random
out-of-tree pcmcia drivers which people use.  Russell would prefer that if
we _do_ have a compat layer it should be implemented in a different manner.

But we're all fairly uncertain that the compat layer is needed - converting
a driver is a pretty simple exercise, and Davd Hinds doesn't intend to
maintain his drivers into 2.6.

So the compatibility layer will probably go away soon, unless something
happens to bring it back into consideration.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
