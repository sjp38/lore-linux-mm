Date: Wed, 10 Sep 2003 12:10:16 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-ID: <20030910191016.GC1461@matchmail.com>
References: <20030828235649.61074690.akpm@osdl.org> <20030910185338.GA1461@matchmail.com> <20030910185537.GB1461@matchmail.com> <20030910114346.025fdb59.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030910114346.025fdb59.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 10, 2003 at 11:43:46AM -0700, Andrew Morton wrote:
> Mike Fedyk <mfedyk@matchmail.com> wrote:
> >
> > I have another oops for you with 2.6.0-test4-mm3-1 and ide-scsi. 
> 
> ide-scsi is a dead duck.  defunct.  kaput.  Don't use it.  It's only being

Ok, I gotcha.

> kept around for weirdo things like IDE-based tape drives, scanners, etc.
> 

But will those devices hit the same code paths that my cp did?

> Just use /dev/hdX directly.

Will do. (actually doing.  I have a really bad cd-rom that insists on
spinning down after each request -- or maybe large seek, not sure.  Needs
replacement.)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
