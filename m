Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA00534
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 10:37:27 -0400
Subject: 2.1.101 dirty page success
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 26 Jun 1998 09:48:37 -0500
Message-ID: <m1hg18fcca.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: SHMFS list <shmfs@flinx.npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I just rewrote the kernel interface to work like bdflush and I have
seen an enourmouse improvement.  It now doesn't irritate the kernel's
memmory management!

I'll get another release of shmfs shortly, so this code can be
reviewed.  I'm going to be a little busy for a bit though.

Just happy and reporting my success!

Eric
