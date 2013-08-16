Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7102C6B0034
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:12:28 -0400 (EDT)
Date: Fri, 16 Aug 2013 10:12:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130816091223.GF2296@suse.de>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
 <20130814185820.GA2753@gmail.com>
 <20130815171250.GA2296@suse.de>
 <20130816042641.GA2893@gmail.com>
 <20130816083347.GD2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130816083347.GD2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Aug 16, 2013 at 09:33:47AM +0100, Mel Gorman wrote:
> On Fri, Aug 16, 2013 at 01:26:41PM +0900, Minchan Kim wrote:
> <SNIP>
> It'll get even more entertaining if/when someone ever tries
> to reimplement zcache although since Dan left I do not believe anyone is
> planning to try.

I should mention that Bob Liu did some work with zcache recently but is
now looking like it'll be dropped from staging. I did not look at the
details and I have no idea if anything else is planned with it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
