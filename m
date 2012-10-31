Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3F0706B0068
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 22:42:10 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so695830pbb.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 19:42:09 -0700 (PDT)
Date: Tue, 30 Oct 2012 19:43:07 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 0/3] zram/zsmalloc promotion
Message-ID: <20121031024307.GA9210@kroah.com>
References: <1351501009-15111-1-git-send-email-minchan@kernel.org>
 <20121031010642.GN15767@bbox>
 <20121031014209.GB2672@kroah.com>
 <20121031020443.GP15767@bbox>
 <20121031021618.GA1142@kroah.com>
 <20121031023947.GA24883@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121031023947.GA24883@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 31, 2012 at 11:39:48AM +0900, Minchan Kim wrote:
> Greg, what do you think about LTSI?
> Is it proper feature to add it? For it, still do I need ACK from mm developers?

It's already in LTSI, as it's in the 3.4 kernel, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
