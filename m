Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA22684
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 21:29:11 -0500
Date: Tue, 19 Jan 1999 19:15:51 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Removing swap lockmap...
In-Reply-To: <871zksqbyq.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.990119191333.900A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On 19 Jan 1999, Zlatko Calusic wrote:

> Yes, this case probably doesn't get enough testing with my current
> setup, so it is quite hard (for me) to prove removing lockmap is
> no-no. Problem is that I don't understand shm swapping very well

Launch some time this proggy to try out shm swapping:

/*
 * Copyright (C) 1999  Andrea Arcangeli
 * shm swapout test
 */

#include <sys/ipc.h>
#include <sys/shm.h>

#define SIZE 16000000

main()
{
	int shmid;
	char *addr, *p;
	if ((shmid = shmget(IPC_PRIVATE, SIZE, IPC_CREAT | 0644)) < 0)
		perror("shmget");
	if ((addr = shmat(shmid, NULL, 0)) < 0)
		perror("shmat");
	for (p = addr; p < addr + SIZE; p+=4096)
		*p = 0;
}

To know if the lockmap is needed you can also reinsert the code and add a
printk() in the test_and_set_bit() path.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
