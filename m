Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EFB9F5F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 17:53:11 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<m1prfj5qxp.fsf@fess.ebiederm.org>
	<20090412185659.GE4394@shareable.org>
	<m11vrxprk6.fsf@fess.ebiederm.org>
	<20090412203107.GH4394@shareable.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 12 Apr 2009 14:53:51 -0700
In-Reply-To: <20090412203107.GH4394@shareable.org> (Jamie Lokier's message of "Sun\, 12 Apr 2009 21\:31\:07 +0100")
Message-ID: <m1tz4tiln4.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH 8/9] vfs: Implement generic revoked file operations
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie@shareable.org> writes:

> Eric W. Biederman wrote:
>> >> revoked_file_ops return 0 from reads (aka EOF). Tell poll the file is
>> >> always ready for I/O and return -EIO from all other operations.
>> >
>> > I think read should return -EIO too.  If a program is reading from a
>> > /proc file (say), and the thing it's reading suddenly disappears, EOF
>> > gives the false impression that it's read to the end of formatted data
>> > from that file and it can process the data as if it's complete, which
>> > is wrong.
>> 
>> Good point EIO is the current read return value for a removed proc file.
>> 
>> For closed pipes, and hung up ttys the read return value is 0, and from
>> my reading that is what bsd returns after a sys_revoke.
>
> A few suggestions below.  Feel free to ignore them on account of the
> basic revoking functionality being more important :-)

I think I will.  This seems to be the part of the code that is easily
approachable and it is going to be easy to have different opinions on,
and there is no one right answer.

For now I'm just going to pick my best understanding of what BSD did.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
