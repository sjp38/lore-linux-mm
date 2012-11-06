Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id CE50B6B004D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:32:14 -0500 (EST)
Date: Tue, 6 Nov 2012 15:32:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/3] zram/zsmalloc promotion
Message-Id: <20121106153213.03e9cc9f.akpm@linux-foundation.org>
In-Reply-To: <1351840367-4152-1-git-send-email-minchan@kernel.org>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com

On Fri,  2 Nov 2012 16:12:44 +0900
Minchan Kim <minchan@kernel.org> wrote:

> This patchset promotes zram/zsmalloc from staging.

The changelogs are distressingly short of *reasons* for doing this!

> Both are very clean and zram have been used by many embedded product
> for a long time.

Well that's interesting.

Which embedded products?  How are they using zram and what benefit are
they observing from it, in what scenarios?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
