Date: Fri, 12 May 2000 11:56:19 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <qwwhfc45ef3.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10005121155160.1988-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 12 May 2000, Christoph Rohland wrote:

> Hi Ingo,
> 
> Your patch breaks my tests again (Which run fine for some time now on
> pre7):
> 
> 11  1  0     0 1631764   1796  12840   0   0     0     2  115 57045   4  95   1
> 10  3  0     0 1420616   1796  12840   0   0     0     0  120 55463   5  95   1
> 9  3  0      0 998032   1796  12840   0   0     0     2  111 49490   4  96   1
> VM: killing process bash
> VM: killing process ipctst
> VM: killing process ipctst

hm, IMHO it really does nothing that should make memory balance worse.
Does the stock kernel work even after a long test?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
