Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 162A16B007E
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 14:45:52 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id v188so63412264wme.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 11:45:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id j143si14252090wmd.65.2016.04.10.11.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Apr 2016 11:45:50 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l6so16545021wml.3
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 11:45:50 -0700 (PDT)
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
 <570678B7.7010802@sandisk.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <570A9F5B.5010600@grimberg.me>
Date: Sun, 10 Apr 2016 21:45:47 +0300
MIME-Version: 1.0
In-Reply-To: <570678B7.7010802@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>, Christoph Hellwig <hch@infradead.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>


>> This is also very interesting for storage targets, which face the same
>> issue.  SCST has a mode where it caches some fully constructed SGLs,
>> which is probably very similar to what NICs want to do.
>
> I think a cached allocator for page sets + the scatterlists that
> describe these page sets would not only be useful for SCSI target
> implementations but also for the Linux SCSI initiator. Today the scsi-mq
> code reserves space in each scsi_cmnd for a scatterlist of
> SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
> sets less memory would be needed per scsi_cmnd.

If we go down this road how about also attaching some driver opaques
to the page sets?

I know of some drivers that can make good use of those ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
