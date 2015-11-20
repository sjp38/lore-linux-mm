Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABCF6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 17:44:38 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so69959986lbb.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 14:44:37 -0800 (PST)
Received: from emh04.mail.saunalahti.fi (emh04.mail.saunalahti.fi. [62.142.5.110])
        by mx.google.com with ESMTPS id p11si1044820lfe.227.2015.11.20.14.44.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 14:44:36 -0800 (PST)
Date: Sat, 21 Nov 2015 00:43:50 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
Message-ID: <20151120224350.GJ18138@blackmetal.musicnaut.iki.fi>
References: <564F9AFF.3050605@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564F9AFF.3050605@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

Hi,

I think you should squash the revert of v1 into this patch, and then
document the crash the original patch caused and how this new patch is
fixing that.

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
