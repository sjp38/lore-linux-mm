Date: Tue, 20 Jan 2004 11:14:41 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.1-mm5
Message-ID: <20040120111441.A14570@infradead.org>
References: <20040120000535.7fb8e683.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040120000535.7fb8e683.akpm@osdl.org>; from akpm@osdl.org on Tue, Jan 20, 2004 at 12:05:35AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Any reason you keep CardServices-compatibility-layer.patch around?
Having a compat layer for old driver around just for some architectures,
thus having drivers that only compile on some for no deeper reasons sounds
like an incredibly bad idea.  Especially when that API is not used by any
intree driver and only in -mm ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
