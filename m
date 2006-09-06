Date: Wed, 6 Sep 2006 17:17:17 +0200
From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: [PATCH 11/21] nbd: limit blk_queue
Message-ID: <20060906151716.GG16721@harddisk-recovery.com>
References: <20060906131630.793619000@chello.nl>> <20060906133954.845224000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060906133954.845224000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 06, 2006 at 03:16:41PM +0200, Peter Zijlstra wrote:
> -		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
> +		disk->queue = blk_init_queue_node_elv(do_nbd_request,
> +				&nbd_lock, -1, "noop");

So what happens if the noop scheduler isn't compiled into the kernel?


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
