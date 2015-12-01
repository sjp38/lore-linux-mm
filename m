Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 819FD6B0254
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 20:18:55 -0500 (EST)
Received: by oies6 with SMTP id s6so108329847oie.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:18:55 -0800 (PST)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0076.outbound.protection.outlook.com. [207.46.100.76])
        by mx.google.com with ESMTPS id v78si35979339oif.55.2015.11.30.17.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 17:18:55 -0800 (PST)
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
References: <564F9AFF.3050605@sandisk.com>
 <20151124231331.GA25591@infradead.org> <5654F169.6070000@sandisk.com>
 <20151125084744.GA16429@infradead.org> <5655CCC0.9010107@sandisk.com>
 <yq1610jf0jk.fsf@sermon.lab.mkp.net>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <565CF57A.4090507@sandisk.com>
Date: Mon, 30 Nov 2015 17:18:50 -0800
MIME-Version: 1.0
In-Reply-To: <yq1610jf0jk.fsf@sermon.lab.mkp.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, James Bottomley <jbottomley@parallels.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

On 11/30/2015 04:57 PM, Martin K. Petersen wrote:
>>>>>> "Bart" == Bart Van Assche <bart.vanassche@sandisk.com> writes:
>
> Bart> This race is hard to trigger. I can trigger it by repeatedly
> Bart> removing and re-adding SRP SCSI devices. Enabling debug options
> Bart> like SLUB debugging and kmemleak helps. I think that is because
> Bart> these debug options slow down the SCSI device removal code and
> Bart> thereby increase the chance that this race is triggered.
>
> Any updates on this? Your updated patch has no reviews.
>
> Should I just revert the original patch for 4.4?

Hello Martin,

Since the original patch caused a regression, please proceed with 
reverting the original patch.

Regarding this patch: is there anyone on the CC-list of this e-mail who 
can review it ?

Thanks,

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
