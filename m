Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD946B005A
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:41:56 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so600911wev.20
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:41:55 -0700 (PDT)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id hv4si888375wjb.119.2014.06.24.08.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:41:54 -0700 (PDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so546123wgg.22
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:41:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140623144831.83abcda7446956e8d7502f09@linux-foundation.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org> <1401747586-11861-7-git-send-email-ddstreet@ieee.org>
 <20140623144831.83abcda7446956e8d7502f09@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 24 Jun 2014 11:41:33 -0400
Message-ID: <CALZtONBra8HJxP-KM5FtMZThfJXe-M0TNqmFq7rJJUzUKA=KEg@mail.gmail.com>
Subject: Re: [PATCHv2 6/6] mm/zpool: prevent zbud/zsmalloc from unloading when used
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Jun 23, 2014 at 5:48 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon,  2 Jun 2014 18:19:46 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add try_module_get() to zpool_create_pool(), and module_put() to
>> zpool_destroy_pool().  Without module usage counting, the driver module(s)
>> could be unloaded while their pool(s) were active, resulting in an oops
>> when zpool tried to access them.
>
> Was wondering about that ;)  We may as well fold
> this fix into "mm/zpool: implement common zpool api to zbud/zsmalloc"?

Yes.  Sorry, I had this pulled out of that because I was trying to
keep the patches logically separated.  But they do need to be
together, to be safe ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
