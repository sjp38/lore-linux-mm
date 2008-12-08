Subject: Re: [PATCH] Fix incorrect use of loose in slub.c
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081205030808.32351.74011.stgit@marcab.local.tull.net>
References: <20081205030808.32351.74011.stgit@marcab.local.tull.net>
Date: Mon, 08 Dec 2008 10:42:54 +0200
Message-Id: <1228725774.31442.0.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Andrew <nick@nick-andrew.net>
Cc: Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-05 at 14:08 +1100, Nick Andrew wrote:
> Fix incorrect use of loose in slub.c
> 
> It should be 'lose', not 'loose'.
> 
> Signed-off-by: Nick Andrew <nick@nick-andrew.net>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
