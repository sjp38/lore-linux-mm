Date: Thu, 11 Sep 2003 10:20:57 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-ID: <20030911082057.GP1396@suse.de>
References: <20030910114346.025fdb59.akpm@osdl.org> <10720000.1063224243@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <10720000.1063224243@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, Mike Fedyk <mfedyk@matchmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 10 2003, Martin J. Bligh wrote:
> >> I have another oops for you with 2.6.0-test4-mm3-1 and ide-scsi. 
> > 
> > ide-scsi is a dead duck.  defunct.  kaput.  Don't use it.  It's only being
> > kept around for weirdo things like IDE-based tape drives, scanners, etc.
> > 
> > Just use /dev/hdX directly.
> 
> That's a real shame ... it seemed to work fine until recently. Some
> of the DVD writers (eg the one I have - Sony DRU500A or whatever)

Then maybe it would be a really good idea to find out why it doesn't
work with ide-cd. What are the symptoms?

> need it. Is it unfixable? or just nobody's done it?

It's not unfixable, there's just not a lot of motivation to fix it since
it's basically dead.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
