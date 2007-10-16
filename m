Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9G7v0cB054434
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 07:57:00 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9G7uxkL2167004
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 09:56:59 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9G7uxuq018928
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 09:56:59 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
Date: Tue, 16 Oct 2007 09:56:57 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <m14pgsknmd.fsf_-_@ebiederm.dsl.xmission.com> <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
In-Reply-To: <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200710160956.58061.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Am Dienstag, 16. Oktober 2007 schrieb Eric W. Biederman:

> fs/buffer.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>  drivers/block/rd.c |   13 +------------
>  1 files changed, 1 insertions(+), 12 deletions(-)

Your patches look sane so far. I have applied both patches, and the problem 
seems gone. I will try to get these patches to our testers.

As long as they dont find new problems:

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

Nick, Eric. What is the best patch for the stable series? Both patches from
Eric or mine? I CCed stable, so they know that something is coming.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
