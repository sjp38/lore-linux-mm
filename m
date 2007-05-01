Date: Tue, 1 May 2007 09:46:23 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: pcmcia ioctl removal
Message-ID: <20070501084623.GB14364@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

>  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch

...

> Dominik is busy.  Will probably re-review and send these direct to Linus.

The patch above is the removal of cardmgr support.  While I'd love to
see this cruft gone it definitively needs maintainer judgement on whether
they time has come that no one relies on cardmgr anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
