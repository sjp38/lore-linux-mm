Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1A56B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:13:38 -0500 (EST)
Received: by pacej9 with SMTP id ej9so36233894pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:13:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id uo3si23105136pac.221.2015.11.24.15.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 15:13:37 -0800 (PST)
Date: Tue, 24 Nov 2015 15:13:31 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
Message-ID: <20151124231331.GA25591@infradead.org>
References: <564F9AFF.3050605@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564F9AFF.3050605@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

What sort of re-registration is this? Seems like we should only
release the minor number once the bdi is released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
