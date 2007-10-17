Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9HLn4CV693190
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 21:49:04 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9HLn4MQ504024
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 23:49:04 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9HLn4KB014875
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 23:49:04 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
Date: Wed, 17 Oct 2007 23:48:23 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <200710171814.01717.borntraeger@de.ibm.com> <m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710172348.23113.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Am Mittwoch, 17. Oktober 2007 schrieb Eric W. Biederman:
> Did you have both of my changes applied?
> To init_page_buffer() and to the ramdisk_set_dirty_page?

Yes, I removed my patch and applied both patches from you. 

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
