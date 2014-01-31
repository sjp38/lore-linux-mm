Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id D08CD6B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 03:20:28 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so6634501qcr.28
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 00:20:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 75si6876442qgv.147.2014.01.31.00.20.28
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 00:20:28 -0800 (PST)
Date: Fri, 31 Jan 2014 03:20:17 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] block devices: validate block device capacity
In-Reply-To: <1391147127.2181.159.camel@dabdike.int.hansenpartnership.com>
Message-ID: <alpine.LRH.2.02.1401310316560.21451@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1401301531040.29912@file01.intranet.prod.int.rdu2.redhat.com>    <1391122163.2181.103.camel@dabdike.int.hansenpartnership.com>    <alpine.LRH.2.02.1401301805590.19506@file01.intranet.prod.int.rdu2.redhat.com>  
 <1391125027.2181.114.camel@dabdike.int.hansenpartnership.com>   <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com>  <1391132609.2181.131.camel@dabdike.int.hansenpartnership.com>  <alpine.LRH.2.02.1401302116180.9767@file01.intranet.prod.int.rdu2.redhat.com>
 <1391147127.2181.159.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org



On Thu, 30 Jan 2014, James Bottomley wrote:

> > So, if you want 64-bit page offsets, you need to increase pgoff_t size, 
> > and that will increase the limit for both files and block devices.
> 
> No.  The point is the page cache mapping of the device uses a
> manufactured inode saved in the backing device. It looks fixable in the
> buffer code before the page cache gets involved.

So if you think you can support 16TiB devices and leave pgoff_t 32-bit, 
send a patch that does it.

Until you make it, you should apply the patch that I sent, that prevents 
kernel lockups or data corruption when the user uses 16TiB device on 
32-bit kernel.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
