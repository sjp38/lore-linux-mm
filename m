Date: 27 Mar 2007 16:09:33 -0400
Message-ID: <20070327200933.6321.qmail@science.horizon.com>
From: linux@horizon.com
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
In-Reply-To: <20070327123422.d0bbc064.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux@horizon.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

> Suggest you use msync(MS_ASYNC), then
> sync_file_range(SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE).

Thank you; I didn't know about that.  And I can handle -ENOSYS by falling
back to the old behavior.

> We can fix your application, and we'll break someone else's.

If you can point to an application that it'll break, I'd be a lot more
understanding.  Nobody did, last year.

> I don't think it's solveable, really - the range of applications is so
> broad, and the "standard" is so vague as to be useless.

I agree that standards are sometimes vague, but that one seemed about
as clear as it's possible to be without imposing unreasonably on
the file system and device driver layers.

What part of "The msync() function writes all modified data to
permanent storage locations [...] For mappings to files, the msync()
function ensures that all write operations are completed as defined
for synchronised I/O data integrity completion." suggests that it's not
supposed to do disk I/O?  How is that uselessly vague?

It says to me that msync's raison d'etre is to write data from RAM to
stable storage.  If an application calls it too often, that's
the application's fault just as if it called sync(2) too often.

> This is why we've
> been extending these things with linux-specific goodies which permit
> applications to actually tell the kernel what they want to be done in a
> more finely-grained fashion.

Well, I still think the current Linux behavior is a bug, but there's a
usable (and run-time compatible) workaround that doesn't unreasonably
complicate the code, and that's good enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
