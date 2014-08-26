Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44BD26B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 04:18:17 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so13995114wgh.34
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 01:18:16 -0700 (PDT)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
        by mx.google.com with ESMTPS id wq4si3078555wjc.39.2014.08.26.01.18.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 01:18:15 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id w62so14405412wes.15
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 01:18:15 -0700 (PDT)
Message-ID: <53FC42C5.6040300@plexistor.com>
Date: Tue, 26 Aug 2014 11:18:13 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>	 <53ECB480.4060104@plexistor.com> <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com>
In-Reply-To: <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/25/2014 11:10 PM, Ross Zwisler wrote:
<>
> I think we can still have a working probe by instead comparing the passed in
> dev_t against the dev_t we get back from disk_to_dev(prd->prd_disk), but I'd
> really like a use case so I can test this.  Until then I think I'm just going
> to stub out prd/pmem_probe() with a BUG() so we can see if anyone hits it.
> 
> It seems like this is preferable to just registering NULL for probe, as that
> would cause an oops in kobj_lookup(() when probe() is blindly called without
> checking for NULL.
> 

I have a version I think you will love it removes the probe and bunch of
other stuff.

I tested it heavily it just works

Comming soon, I'm preparing trees right now
Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
