Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 601DA6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 20:18:47 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id ox1so117764veb.9
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:18:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130814161753.GB2706@gmail.com>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
	<CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
	<20130814161753.GB2706@gmail.com>
Date: Thu, 15 Aug 2013 08:18:46 +0800
Message-ID: <CAA_GA1da3jkOO9Y3+L6_DMmiH8wsbJJ-xcUxUK_Gh2SYPPbjoA@mail.gmail.com>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

On Thu, Aug 15, 2013 at 12:17 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Luigi,
>
> On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
>> During earlier discussions of zswap there was a plan to make it work
>> with zsmalloc as an option instead of zbud. Does zbud work for
>
> AFAIR, it was not an optoin but zsmalloc was must but there were
> several objections because zswap's notable feature is to dump
> compressed object to real swap storage. For that, zswap needs to
> store bounded objects in a zpage so that dumping could be bounded, too.
> Otherwise, it could encounter OOM easily.
>

AFAIR, the next step of zswap should be have a modular allocation layer so that
users can choose zsmalloc or zbud to use.

Seth?

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
