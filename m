Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id D96016B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 03:15:12 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so10448145qcy.40
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 00:15:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v46si5242101qgv.150.2014.02.03.00.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 00:15:12 -0800 (PST)
Date: Mon, 3 Feb 2014 00:15:06 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] block devices: validate block device capacity
Message-ID: <20140203081506.GA10961@infradead.org>
References: <alpine.LRH.2.02.1401301531040.29912@file01.intranet.prod.int.rdu2.redhat.com>
 <1391122163.2181.103.camel@dabdike.int.hansenpartnership.com>
 <alpine.LRH.2.02.1401301805590.19506@file01.intranet.prod.int.rdu2.redhat.com>
 <1391125027.2181.114.camel@dabdike.int.hansenpartnership.com>
 <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com>
 <1391132609.2181.131.camel@dabdike.int.hansenpartnership.com>
 <alpine.LRH.2.02.1401302116180.9767@file01.intranet.prod.int.rdu2.redhat.com>
 <1391147127.2181.159.camel@dabdike.int.hansenpartnership.com>
 <alpine.LRH.2.02.1401310316560.21451@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1401310316560.21451@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Jens Axboe <axboe@kernel.dk>, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 31, 2014 at 03:20:17AM -0500, Mikulas Patocka wrote:
> So if you think you can support 16TiB devices and leave pgoff_t 32-bit, 
> send a patch that does it.
> 
> Until you make it, you should apply the patch that I sent, that prevents 
> kernel lockups or data corruption when the user uses 16TiB device on 
> 32-bit kernel.

Exactly.  I had actually looked into support for > 16TiB devices for
a NAS use case a while ago, but when explaining the effort involves
the idea was dropped quickly.  The Linux block device is too deeply
tied to the pagecache to make it easily feasible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
