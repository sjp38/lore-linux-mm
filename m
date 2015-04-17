Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A49106B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 00:29:11 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so16316539qge.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 21:29:11 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id 93si10564133qkr.115.2015.04.16.21.29.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 21:29:10 -0700 (PDT)
Received: by qcbii10 with SMTP id ii10so18259839qcb.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 21:29:10 -0700 (PDT)
Date: Fri, 17 Apr 2015 00:28:47 -0400
From: Michael Tirado <mtirado418@gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd:
 F_SEAL_WRITE_NONCREATOR
Message-ID: <20150417002847.1f5febf7@yak.slack>
In-Reply-To: <CANq1E4SbenR0-N4oLBMUe_2iiduU1TReA1RRTMA9_+h_mGwNOw@mail.gmail.com>
References: <20150416032316.00b79732@yak.slack>
	<CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
	<CANq1E4SbenR0-N4oLBMUe_2iiduU1TReA1RRTMA9_+h_mGwNOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-mm@kvack.org


David, 
Thank you for the reply and your work on memfd.
It's been a fun learning experience working with this code.

On Thu, 16 Apr 2015 14:01:07 +0200
David Herrmann <dh.herrmann@gmail.com> wrote:

> No. This is not what sealing is about. Seals are a property of an
> object, they're unrelated to the process accessing it. Sealing is not
> an access-control method, but describes the state and capabilities of
> a file.

The comments on sealing at the top of shmem_add_seals lead me to believe 
that seals were in place specifically for access control purposes.


> The same functionality of F_SEAL_WRITE_NONCREATOR can be achieved by
> opening /proc/self/fd/<num> with O_RDONLY. Just pass that read-only FD
> to your peers but retain the writable one. But note that you must
> verify your peers do not have the same uid as you do, otherwise they
> can just gain a writable descriptor by opening /proc/self/fd/<num>
> themselves.
> 
> Thanks
> David

My peers may be any uid, in the same or different pid namespace. 
I would really like to not have to maintain an AF_UNIX connection to receive 
memfd's with a write seal.  It does make a lot of sense for multicasting, 
but I feel memfd would be more versitile if there was a concept of ownership, 
or directionality, so a user could shed the socket after SCM_RIGHTS message or
even fork without a socket at all.  I am more than willing to put in the work 
if someone can offer advice on how to better achieve this type of shared 
memory.  Maybe it's already out there and I just didn't know where to look?

-Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
