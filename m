Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 268C46B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 00:24:09 -0400 (EDT)
Date: Thu, 25 Apr 2013 00:24:05 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: WARNING: at fs/ext4/inode.c:3222
Message-ID: <20130425042405.GB4685@thunk.org>
References: <84952911.2068510.1366860446300.JavaMail.root@redhat.com>
 <825854245.2071098.1366861400988.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <825854245.2071098.1366861400988.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: linux-ext4@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Steve Best <sbest@redhat.com>

On Wed, Apr 24, 2013 at 11:43:20PM -0400, CAI Qian wrote: 
> OK, this is to test the latest ext4 dev tree on power 7 systems
> running xfstests,

Thanks for reporting this.  Was this warning thrown while xfstests 224
was running?  (I like to make sure the xfstests output is sent to the
console so the kernel messages are intermixed with the xfstests
output, so it's clear which test triggered the warning.)

If so, can you reproduce the problem running xfstest #224 all by
itself?

Thanks,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
