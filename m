Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31E706B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:18:04 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p189so12444666iod.2
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:18:04 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id 81si159449ioh.195.2018.02.14.09.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 09:18:02 -0800 (PST)
Date: Wed, 14 Feb 2018 11:18:00 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v1] mm: Re-use DEFINE_SHOW_ATTRIBUTE() macro
In-Reply-To: <20180214160409.GA25747@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802141117400.26770@nuc-kabylake>
References: <20180214154644.54505-1-andriy.shevchenko@linux.intel.com> <20180214160409.GA25747@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Tejun Heo <tj@kernel.org>, Dennis Zhou <dennisszhou@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


Acked-by: Christoph Lameter <cl@linux.com>

On Wed, 14 Feb 2018, Matthew Wilcox wrote:

> On Wed, Feb 14, 2018 at 05:46:44PM +0200, Andy Shevchenko wrote:
> > ...instead of open coding file operations followed by custom ->open()
> > callbacks per each attribute.
> >
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
>
> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
