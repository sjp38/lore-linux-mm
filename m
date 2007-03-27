In-reply-to: <20070327200933.6321.qmail@science.horizon.com>
	(linux@horizon.com)
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <20070327200933.6321.qmail@science.horizon.com>
Message-Id: <E1HWIKP-0004oj-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 27 Mar 2007 22:31:37 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux@horizon.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Suggest you use msync(MS_ASYNC), then
> > sync_file_range(SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE).
> 
> Thank you; I didn't know about that.  And I can handle -ENOSYS by falling
> back to the old behavior.
> 
> > We can fix your application, and we'll break someone else's.
> 
> If you can point to an application that it'll break, I'd be a lot more
> understanding.  Nobody did, last year.
> 
> > I don't think it's solveable, really - the range of applications is so
> > broad, and the "standard" is so vague as to be useless.
> 
> I agree that standards are sometimes vague, but that one seemed about
> as clear as it's possible to be without imposing unreasonably on
> the file system and device driver layers.
> 
> What part of "The msync() function writes all modified data to
> permanent storage locations [...] For mappings to files, the msync()
> function ensures that all write operations are completed as defined
> for synchronised I/O data integrity completion." suggests that it's not
> supposed to do disk I/O?  How is that uselessly vague?

Linux _will_ write all modified data to permanent storage locations.
Since 2.6.17 it will do this regardless of msync().  Before 2.6.17 you
do need msync() to enable data to be written back.

But it will not start I/O immediately, which is not a requirement in
the standard, or at least it's pretty vague about that.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
