Date: Thu, 7 Aug 2003 09:00:31 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.0-test2-mm5
Message-ID: <20030807090031.A12476@infradead.org>
References: <20030806223716.26af3255.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030806223716.26af3255.akpm@osdl.org>; from akpm@osdl.org on Wed, Aug 06, 2003 at 10:37:16PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 06, 2003 at 10:37:16PM -0700, Andrew Morton wrote:
> +devfs-pty-slave-fix.patch
> 
>  devfs fix

This patch is wrong.  Those nodes are managed by devpts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
