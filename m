Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 76DA1600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 13:59:16 -0500 (EST)
Subject: Re: [PATCH] mm: don't discard unused swap slots by default
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <20091030065102.GA2896@lst.de>
	<Pine.LNX.4.64.0910301629030.4106@sister.anvils>
	<20091118171232.GB25541@lst.de> <20091130172243.GA30779@lst.de>
	<Pine.LNX.4.64.0911301752070.10043@sister.anvils>
Date: Mon, 30 Nov 2009 13:58:39 -0500
In-Reply-To: <Pine.LNX.4.64.0911301752070.10043@sister.anvils> (Hugh Dickins's
	message of "Mon, 30 Nov 2009 18:28:41 +0000 (GMT)")
Message-ID: <yq1aay3261s.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Hugh" == Hugh Dickins <hugh.dickins@tiscali.co.uk> writes:

Hugh> You mentioned an "-o discard" mount option before: so I think what
Hugh> we ought to be doing is an option to swapon.  But you can imagine
Hugh> that I'd prefer to avoid that too, if we can work this out without
Hugh> it.

The main problem we have is that the devices currently supporting TRIM
are doing a piss poor job at it.

We have pretty good vendor guarantees that discards are going to be
essentially free on SCSI-class hardware.  But in the ATA space things
are currently being driven by early adopters / tweakers that care more
about benchmarketing and feature checklists.  Whether things actually
work as intended is mostly irrelevant.

I think we'll need to give things a little bit of time for decent ATA
TRIM implementations to materialize.  And then we can switch to an
"assume it works, blacklist bad eggs" approach.  Until then I think we
need to make discard an explicit opt-in feature.

-- 
Martin K. Petersen	Oracle Linux Engineering

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
