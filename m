Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3F8FKwt184884
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 08:15:20 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3F8FKrs4038868
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 10:15:20 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3F8FKg8001371
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 10:15:20 +0200
Subject: Re: [patch 17/19] Use kbuild.h instead of defining macros in
	asm-offsets.c
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20080414221848.428938934@sgi.com>
References: <20080414221808.269371488@sgi.com>
	 <20080414221848.428938934@sgi.com>
Content-Type: text/plain
Date: Tue, 15 Apr 2008 10:14:04 +0200
Message-Id: <1208247244.3664.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-04-14 at 15:18 -0700, Christoph Lameter wrote:
> s390 has a strange marker in DEFINE. Undefine the DEFINE from kbuild.h and define
> it the way s390 wants it to preserve things as they were.

That is a leftover from the very first version of the asm-offsets code.
All the DEFINEs in arch/s390/kernel/asm-offsets.c have an empty third
argument, we never needed it.

> May be good if the arch maintainer could go over this and check if this workaround
> is really necessary.

No, the workaround can go. We can use the default macro if the DEFINE
lines get adapted: "s/,);/\);/"

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
