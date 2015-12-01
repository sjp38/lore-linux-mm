Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BCEE36B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 02:23:24 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so212902986pac.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 23:23:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id fk1si15881943pad.35.2015.11.30.23.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 23:23:23 -0800 (PST)
Date: Mon, 30 Nov 2015 23:23:15 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
Message-ID: <20151201072315.GA12183@infradead.org>
References: <564F9AFF.3050605@sandisk.com>
 <20151124231331.GA25591@infradead.org>
 <5654F169.6070000@sandisk.com>
 <20151125084744.GA16429@infradead.org>
 <5655CCC0.9010107@sandisk.com>
 <yq1610jf0jk.fsf@sermon.lab.mkp.net>
 <565CF57A.4090507@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565CF57A.4090507@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, Christoph Hellwig <hch@infradead.org>, James Bottomley <jbottomley@parallels.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

On Mon, Nov 30, 2015 at 05:18:50PM -0800, Bart Van Assche wrote:
> Since the original patch caused a regression, please proceed with reverting
> the original patch.
> 
> Regarding this patch: is there anyone on the CC-list of this e-mail who can
> review it ?

I'm not too fond of the approach.  I'd much prefer if SCSI would just
release the dev_t later, similar to DM or MD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
