Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9I9QCG2467308
	for <linux-mm@kvack.org>; Thu, 18 Oct 2007 09:26:12 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I9QBoX1786092
	for <linux-mm@kvack.org>; Thu, 18 Oct 2007 11:26:12 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I9QB7h030669
	for <linux-mm@kvack.org>; Thu, 18 Oct 2007 11:26:11 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
Date: Thu, 18 Oct 2007 11:26:10 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <200710172348.23113.borntraeger@de.ibm.com> <m1myuhcrfu.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1myuhcrfu.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710181126.10559.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 18. Oktober 2007 schrieb Eric W. Biederman:
> Grr. Inconsistent rules on a core piece of infrastructure.
> It looks like that if there is any trivial/minimal fix it
> is based on your patch suppressing try_to_free_buffers.  Ugh.
> 
> Eric

Ok. What do you think about having my patch for 2.6.23 stable, for 2.6.24
and doing a nicer fix (rd rewrite for example for post 2.6.24)?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
