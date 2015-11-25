Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 188936B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:59:18 -0500 (EST)
Received: by qgec40 with SMTP id c40so33486406qge.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:59:17 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0078.outbound.protection.outlook.com. [65.55.169.78])
        by mx.google.com with ESMTPS id g109si21338358qgf.43.2015.11.25.06.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 06:59:17 -0800 (PST)
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
References: <564F9AFF.3050605@sandisk.com>
 <20151124231331.GA25591@infradead.org> <5654F169.6070000@sandisk.com>
 <20151125084744.GA16429@infradead.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5655CCC0.9010107@sandisk.com>
Date: Wed, 25 Nov 2015 06:59:12 -0800
MIME-Version: 1.0
In-Reply-To: <20151125084744.GA16429@infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

On 11/25/15 00:47, Christoph Hellwig wrote:
> But what I really wanted to ask for is what your reproducer looks like.

Hello Christoph,

This race is hard to trigger. I can trigger it by repeatedly removing 
and re-adding SRP SCSI devices. Enabling debug options like SLUB 
debugging and kmemleak helps. I think that is because these debug 
options slow down the SCSI device removal code and thereby increase the 
chance that this race is triggered.

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
