Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9G8mxOU1091346
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 08:48:59 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9G8mxIG2162882
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 10:48:59 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9G8mxAn005154
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 10:48:59 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
Date: Tue, 16 Oct 2007 10:48:56 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com> <200710161819.11231.nickpiggin@yahoo.com.au>
In-Reply-To: <200710161819.11231.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161048.56848.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Am Dienstag, 16. Oktober 2007 schrieb Nick Piggin:
> While I said it was a good fix when I saw the patch earlier, I think
> it's not closing the entire hole, and as such, Christian's patch is
> probably the way to go for stable.

That would be my preferred method. Merge Erics and my fixup for 2.6.24-rc.
The only open questions is, what was the reiserfs problem? Is it still
causes by Erics patches?

> For mainline, *if* we want to keep the old rd.c around at all, I
> don't see any harm in this patch so long as Christian's is merged
> as well. Sharing common code is always good.

While the merge window is still open, to me the new ramdisk code seems
more like a 2.6.25-rc thing. We actually should test the behaviour in 
low memory scenarios. What do you think?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
