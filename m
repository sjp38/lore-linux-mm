Date: Thu, 11 Sep 2003 11:30:55 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-ID: <20030911183055.GF18399@matchmail.com>
References: <20030910114346.025fdb59.akpm@osdl.org> <10720000.1063224243@flay> <20030911082057.GP1396@suse.de> <63090000.1063303982@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63090000.1063303982@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 11, 2003 at 11:13:02AM -0700, Martin J. Bligh wrote:
> >> That's a real shame ... it seemed to work fine until recently. Some
> >> of the DVD writers (eg the one I have - Sony DRU500A or whatever)
> > 
> > Then maybe it would be a really good idea to find out why it doesn't
> > work with ide-cd. What are the symptoms?
> 
> Symptoms are that it required cdrecord-pro, which was a closed source
> piece of turd I can't do much with ;-)

Are you using the version of cdrecord with Linus' patch when he added CDR capability to
ide-cd?

I know it has been in debian testing for a while now...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
