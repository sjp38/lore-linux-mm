From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] block: Isolate the buffer cache in it's own mappings.
Date: Sun, 21 Oct 2007 14:24:46 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <20071017213216.b2d0c4bd.akpm@linux-foundation.org> <m11wbqg5he.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m11wbqg5he.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710211424.46650.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 20 October 2007 07:27, Eric W. Biederman wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> > I don't think we little angels want to tread here.  There are so many
> > weirdo things out there which will break if we bust the coherence between
> > the fs and /dev/hda1.
>
> We broke coherence between the fs and /dev/hda1 when we introduced
> the page cache years ago,

Not for metadata. And I wouldn't expect many filesystem analysis
tools to care about data.


> and weird hacky cases like 
> unmap_underlying_metadata don't change that.

unmap_underlying_metadata isn't about raw block device access at
all, though (if you write to the filesystem via the blockdevice
when it isn't expecting it, it's going to blow up regardless).


> Currently only 
> metadata is more or less in sync with the contents of /dev/hda1.

It either is or it isn't, right? And it is, isn't it? (at least
for the common filesystems).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
