From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] rewrite ramdisk
Date: Wed, 17 Oct 2007 08:08:30 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710161747.12968.nickpiggin@yahoo.com.au> <20071016212853.GB1314@closure.lan>
In-Reply-To: <20071016212853.GB1314@closure.lan>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710170808.30944.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 17 October 2007 07:28, Theodore Tso wrote:
> On Tue, Oct 16, 2007 at 05:47:12PM +1000, Nick Piggin wrote:
> > +	/*
> > +	 * ram device BLKFLSBUF has special semantics, we want to actually
> > +	 * release and destroy the ramdisk data.
> > +	 */
>
> We won't be able to fix completely this for a while time, but the fact
> that BLKFLSBUF has special semantics has always been a major wart.
> Could we perhaps create a new ioctl, say RAMDISKDESTORY, and add a
> deperecation printk for BLKFLSBUF when passed to the ramdisk?  I doubt
> there are many tools that actually take advantage of this wierd aspect
> of ramdisks, so hopefully it's something we could remove in a 18
> months or so...

It would be nice to be able to do that, I agree. The new ramdisk
code will be able to flush the buffer cache and destroy its data
separately, so it can actually be implemented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
