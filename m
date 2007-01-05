Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l058HSTZ060616
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 08:17:29 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l058HSiG3231968
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 09:17:28 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l058HSTT029843
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 09:17:28 +0100
In-Reply-To: <ada8xgi5w0n.fsf@cisco.com>
Subject: Re: do we have mmap abuse in ehca ?, was Re:  mmap abuse in ehca
Message-ID: <OFBD9A4186.C6AB9FD1-ONC125725A.002D32C5-C125725A.002D8B42@de.ibm.com>
From: Christoph Raisch <RAISCH@de.ibm.com>
Date: Fri, 5 Jan 2007 09:17:27 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland Dreier <rdreier@cisco.com>
Cc: Christoph Hellwig <hch@infradead.org>, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roland Dreier <rdreier@cisco.com> wrote on 04.01.2007 22:20:40:

> Sorry I missed this original thread (on vacation since mid-December,
> just back today).  Anyway...
>
> ehca guys -- where do we stand on fixing this up?

We're looking into it.
It's a non-trivial change, because both kernel and userspace
driver have to be in sync again and need a good amount of test.

And beginning next week the christmas holiday season will be over.

Christoph Raisch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
