Date: Tue, 25 Nov 2008 17:20:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/9] swapfile: swapon randomize if nonrot
Message-Id: <20081125172039.c9a35460.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0811252146090.20455@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
	<Pine.LNX.4.64.0811252140230.17555@blonde.site>
	<Pine.LNX.4.64.0811252146090.20455@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: dwmw2@infradead.org, jens.axboe@oracle.com, matthew@wil.cx, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008 21:46:56 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> But how to get my SD card, accessed by USB card reader, reported as NONROT?

Dunno.  udev rules, perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
