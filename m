Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACEC6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 05:00:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so4815468pfi.9
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 02:00:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si16402365plk.308.2018.04.09.02.00.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 02:00:20 -0700 (PDT)
Date: Mon, 9 Apr 2018 11:00:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Block layer use of __GFP flags
Message-ID: <20180409090016.GA21771@dhcp22.suse.cz>
References: <20180408065425.GD16007@bombadil.infradead.org>
 <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
 <20180408190825.GC5704@bombadil.infradead.org>
 <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "willy@infradead.org" <willy@infradead.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hare@suse.com" <hare@suse.com>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "axboe@kernel.dk" <axboe@kernel.dk>

On Mon 09-04-18 04:46:22, Bart Van Assche wrote:
[...]
[...]
> diff --git a/drivers/ide/ide-pm.c b/drivers/ide/ide-pm.c
> index ad8a125defdd..3ddb464b72e6 100644
> --- a/drivers/ide/ide-pm.c
> +++ b/drivers/ide/ide-pm.c
> @@ -91,7 +91,7 @@ int generic_ide_resume(struct device *dev)
>  
>  	memset(&rqpm, 0, sizeof(rqpm));
>  	rq = blk_get_request_flags(drive->queue, REQ_OP_DRV_IN,
> -				   BLK_MQ_REQ_PREEMPT);
> +				   BLK_MQ_REQ_PREEMPT, __GFP_RECLAIM);

Is there any reason to use __GFP_RECLAIM directly. I guess you wanted to
have GFP_NOIO semantic, right? So why not be explicit about that. Same
for other instances of this flag in the patch
-- 
Michal Hocko
SUSE Labs
