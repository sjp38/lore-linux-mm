From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] block: Isolate the buffer cache in it's own mappings.
Date: Thu, 18 Oct 2007 15:10:48 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <1192665785.15717.34.camel@think.oraclecorp.com> <m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
In-Reply-To: <m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710181510.48382.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Chris Mason <chris.mason@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 18 October 2007 13:59, Eric W. Biederman wrote:
> If filesystems care at all they want absolute control over the buffer
> cache.  Controlling which buffers are dirty and when.  Because we
> keep the buffer cache in the page cache for the block device we have
> not quite been giving filesystems that control leading to really weird
> bugs.

Mmm. Like I said, when a live filesystem is mounted on a bdev,
it isn't like you want userspace to go dancing around on it without
knowing exactly what it is doing.

The kernel more or less does the right thing here with respect to
the *state* of the data[*] (that is, buffer heads and pagecache).
It's when you actually start changing the data itself around is when
you'll blow up the filesystem.

[*] The ramdisk code is simply buggy, right? (and not the buffer
    cache)

The idea of your patch in theory is OK, but Andrew raises valid
points about potential coherency problems, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
