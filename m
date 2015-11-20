Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 828356B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 17:55:51 -0500 (EST)
Received: by qgeb1 with SMTP id b1so83115064qge.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 14:55:51 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0096.outbound.protection.outlook.com. [65.55.169.96])
        by mx.google.com with ESMTPS id 129si1723333qhi.75.2015.11.20.14.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 14:55:50 -0800 (PST)
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
References: <564F9AFF.3050605@sandisk.com>
 <20151120224350.GJ18138@blackmetal.musicnaut.iki.fi>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <564FA4F1.5000108@sandisk.com>
Date: Fri, 20 Nov 2015 14:55:45 -0800
MIME-Version: 1.0
In-Reply-To: <20151120224350.GJ18138@blackmetal.musicnaut.iki.fi>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 11/20/2015 02:44 PM, Aaro Koskinen wrote:
> I think you should squash the revert of v1 into this patch, and then
> document the crash the original patch caused and how this new patch is
> fixing that.

Hello Aaro,

I'd like to know the opinion of the SCSI maintainers about this. It's 
not impossible that they would prefer to submit the revert to Linus 
quickly and only send the reworked fix to Linus during the v4.5 merge 
window.

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
