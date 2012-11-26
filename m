Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 520886B004D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 11:45:58 -0500 (EST)
Date: Mon, 26 Nov 2012 11:45:55 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126164555.GL31891@thunk.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bugzilla-daemon@bugzilla.kernel.org
Cc: meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 04:33:28PM +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=50981
>
> as this is working properly with XFS, so in ext4/ext3...etc also we shouldn't
> require synchronization at the Application level,., FS should take care of
> locking... will we expecting the fix for the same ???

Meetmehiro,

At this point, there seems to be consensus that the kernel should take
care of the locking, and that this is not something that needs be a
worry for the application.  Whether this should be done in the file
system layer or in the mm layer is the current question at hand ---
since this is a bug that also affects btrfs and other non-XFS file
systems.

So the question is whether every file system which supports AIO should
add its own locking, or whether it should be done at the mm layer, and
at which point the lock in the XFS layer could be removed as no longer
necessary.

I've added linux-mm and linux-fsdevel to make sure all of the relevant
kernel developers are aware of this question/issue.

Regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
