Date: Wed, 10 Sep 2003 13:04:03 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-ID: <10720000.1063224243@flay>
In-Reply-To: <20030910114346.025fdb59.akpm@osdl.org>
References: <20030828235649.61074690.akpm@osdl.org><20030910185338.GA1461@matchmail.com><20030910185537.GB1461@matchmail.com> <20030910114346.025fdb59.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Mike Fedyk <mfedyk@matchmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> I have another oops for you with 2.6.0-test4-mm3-1 and ide-scsi. 
> 
> ide-scsi is a dead duck.  defunct.  kaput.  Don't use it.  It's only being
> kept around for weirdo things like IDE-based tape drives, scanners, etc.
> 
> Just use /dev/hdX directly.

That's a real shame ... it seemed to work fine until recently. Some
of the DVD writers (eg the one I have - Sony DRU500A or whatever)
need it. Is it unfixable? or just nobody's done it?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
