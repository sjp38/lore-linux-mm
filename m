Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id l2NLuDBJ021202
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 21:56:13 GMT
Received: from an-out-0708.google.com (ancc35.prod.google.com [10.100.29.35])
	by spaceape8.eur.corp.google.com with ESMTP id l2NLth7s030274
	for <linux-mm@kvack.org>; Fri, 23 Mar 2007 21:56:08 GMT
Received: by an-out-0708.google.com with SMTP id c35so1433857anc
        for <linux-mm@kvack.org>; Fri, 23 Mar 2007 14:56:07 -0700 (PDT)
Message-ID: <b040c32a0703231456u298186c6o1ec7199bfdbe7f65@mail.gmail.com>
Date: Fri, 23 Mar 2007 14:56:07 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
In-Reply-To: <20070323150346.GU2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
	 <20070323150346.GU2986@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 3/23/07, William Lee Irwin III <wli@holomorphy.com> wrote:
> I like this patch a lot, though I'm not likely to get around to testing
> it today. If userspace testcode is available that would be great to see
> posted so I can just boot into things and run that.

Here is the test code that I used:
(warning: x86 centric)

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

#define SIZE	(4*1024*1024UL)

int main(void)
{
	int fd;
	long i;
	char *addr;

	fd = open("/dev/hugetlb", O_RDWR);
	if (fd == -1) {
		perror("open failure");
		exit(1);
	}

	addr = mmap(0, SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (addr == MAP_FAILED) {
		perror("mmap failure");
		exit(2);
	}

	for (i = 0; i < SIZE; i+=4096)
		addr[i] = 1;

	printf("success!\n");
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
