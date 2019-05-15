Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88148C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 250222084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 250222084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70806B0003; Wed, 15 May 2019 11:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A20A96B0006; Wed, 15 May 2019 11:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2716B0008; Wed, 15 May 2019 11:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 256696B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:11:34 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so451008ljj.18
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=o9KH8miEs5dR0YJKfCPnpH+i3MKYE/9tCnRbN/Hl3J0=;
        b=eJpT0ZjjbWm3VK9wq/shN9XOVprsjdl02kPWuOd8FJPFmPVQU6fFa0uJXDJNf9iQBa
         V9BuKiOz7WVA6DLlFxfCfNKFsYb4fgptwYqochZGfAcnk67U0XphQ8Ld2fMX9VKv6U2C
         mkMt581Xwx+kR8YJKu1xKf2+keBrLURntD7y4nYPAv0hKVyXAgx/FMUpzfSq5JnKG/un
         RNvvS1VdCgUyRUUr9BTNW5mBM/xtp/b7t7nnq00JRwQ/VehdD3CLE74ZnXEsdutdSvv7
         BCskVgTbu1NxIyCufi+TopBE64jBQk440gwou8bSvJGdAqQLskk+J6hOW9BHKxPmwNhL
         BGyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXzoIwyc9VL1U20ndJWq5AqL+yqb78Zhshyw2pG4mn1G1DAavTO
	YQi0KcU5Vi6ndv+v8ES22DecvpEmN+Co9PpMlx2NyFS+eAShk6V/TYk+v75dCKrerM1JMPmq9NE
	4LAbm9ZQucGF4229j2PbAj0UM0T3q9hhCFFbgx2Cc83erPT5+8HUyK+j84sC17XuO9Q==
X-Received: by 2002:a2e:809a:: with SMTP id i26mr11778912ljg.182.1557933093474;
        Wed, 15 May 2019 08:11:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTWBdm+fuaswqabS4paioEMnpbTFiCZyChM+i9Br7VJIKbKI3Segb9ujTH1jGqDr3wbD0a
X-Received: by 2002:a2e:809a:: with SMTP id i26mr11778866ljg.182.1557933092309;
        Wed, 15 May 2019 08:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933092; cv=none;
        d=google.com; s=arc-20160816;
        b=xthBWlL4a/FdjKOGDFNzzwwMYiYfrZ97goF2n+sTPt5wNhM/qH6msaHe9+fZkEiWVM
         wGm9tZcIdcR72a6EfLd/2pC9Oa35ri3Vf+ACxdTk3X9NbXzAt7eSXOY6W+zf4+1ySrpC
         B4ZP6oODnMvPsUQgE57FF+RK5MiNz96KyOwPIBFOwAiFzl9Ji1vrQiSzPA+gA+RndYzl
         rCbQCB+HtGlpREgdeuagVMIpULNi4Q3vRYHHIzvwE66UkDr8JHEeQHsPDQTkSK2116z6
         eENsiIv93aWWK856mc0y1m/UYL5lfFlqi5hE3lwKwPj2BdkBRZ+zkM4/sPp1raF502Xo
         99yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=o9KH8miEs5dR0YJKfCPnpH+i3MKYE/9tCnRbN/Hl3J0=;
        b=1BRW/ggjPS/vwRRs8euW1lbRkWX04eAv+95UYOaqzK4QeSoX4dcn56YTCrmZhVTQhP
         mmx3i2gp1OWs9GaSqUNqrng/qGhmL/1/9GV/yKZOx/CazQVGkwMJu2e7D6lZjyft0JXG
         WbrotNy/ttXEYJTJOBTnnAZyTe9iWS7VGlslNWQuZ8DIoMT9eoS/stMHlfFUShKwv9au
         kfX5brh3HwA5jOfJpiMbt7EGPJPfsYlt4T345uc97QVJRHyCboJW2nwXXSguOPHq51dw
         MCcRs3OrONgWwzHf8W3on1Gy7UwcFvOhWwsPD9XtIMJ9CRaGe8pJqBIPpZAJ/uqCTYLC
         oYeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id c10si2030161lji.202.2019.05.15.08.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQvYr-0001X3-3M; Wed, 15 May 2019 18:11:17 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 15 May 2019 18:11:15 +0300
Message-ID: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset adds a new syscall, which makes possible
to clone a mapping from a process to another process.
The syscall supplements the functionality provided
by process_vm_writev() and process_vm_readv() syscalls,
and it may be useful in many situation.

For example, it allows to make a zero copy of data,
when process_vm_writev() was previously used:

	struct iovec local_iov, remote_iov;
	void *buf;

	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
	recv(sock, buf, n * PAGE_SIZE, 0);

	local_iov->iov_base = buf;
	local_iov->iov_len = n * PAGE_SIZE;
	remove_iov = ...;

	process_vm_writev(pid, &local_iov, 1, &remote_iov, 1 0);
	munmap(buf, n * PAGE_SIZE);

	(Note, that above completely ignores error handling)

There are several problems with process_vm_writev() in this example:

1)it causes pagefault on remote process memory, and it forces
  allocation of a new page (if was not preallocated);

2)amount of memory for this example is doubled in a moment --
  n pages in current and n pages in remote tasks are occupied
  at the same time;

3)received data has no a chance to be properly swapped for
  a long time.

The third is the most critical in case of remote process touches
the data pages some time after process_vm_writev() was made.
Imagine, node is under memory pressure:

a)kernel moves @buf pages into swap right after recv();
b)process_vm_writev() reads the data back from swap to pages;
c)process_vm_writev() allocates duplicate pages in remote
  process and populates them;
d)munmap() unmaps @buf;
e)5 minutes later remote task touches data.

In stages "a" and "b" kernel submits unneeded IO and makes
system IO throughput worse. To make "b" and "c", kernel
reclaims memory, and moves pages of some other processes
to swap, so they have to read pages from swap back. Also,
unneeded copying of pages is occured, while zero-copy is
more preferred.

We observe similar problem during online migration of big enough
containers, when after doubling of container's size, the time
increases 100 times. The system resides under high IO and
throwing out of useful cashes.

The proposed syscall aims to introduce an interface, which
supplements currently existing process_vm_writev() and
process_vm_readv(), and allows to solve the problem with
anonymous memory transfer. The above example may be rewritten as:

	void *buf;

	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
	recv(sock, buf, n * PAGE_SIZE, 0);

	/* Sign of @pid is direction: "from @pid task to current" or vice versa. */
	process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
	munmap(buf, n * PAGE_SIZE);

It is swap-friendly: in case of memory is swapped right after recv(),
the syscall just copies pagetable entries like we do on fork(),
so real access to pages does not occurs, and no IO is needed.
No excess pages are reclaimed, and number of pages is not doubled.
Also, zero-copy takes a place, and this also reduces overhead.

The patchset does not introduce much new code, since we simply
reuse existing copy_page_range() and copy_vma() functions.
We extend copy_vma() to be able merge VMAs in remote task [2/5],
and teach copy_page_range() to work with different local and
remote addresses [3/5]. Patch [5/5] introduces the syscall logic,
which mostly consists of sanity checks. The rest of patches
are preparations.

This syscall may be used for page servers like in example
above, for migration (I assume, even virtual machines may
want something like this), for zero-copy desiring users
of process_vm_writev() and process_vm_readv(), for debug
purposes, etc. It requires the same permittions like
existing proc_vm_xxx() syscalls have.

The tests I used may be obtained here:

[1]https://gist.github.com/tkhai/198d32fdc001ec7812a5e1ccf091f275
[2]https://gist.github.com/tkhai/f52dbaeedad5a699f3fb386fda676562

---

Kirill Tkhai (5):
      mm: Add process_vm_mmap() syscall declaration
      mm: Extend copy_vma()
      mm: Extend copy_page_range()
      mm: Export round_hint_to_min()
      mm: Add process_vm_mmap()


 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    2 
 include/linux/huge_mm.h                |    6 +
 include/linux/mm.h                     |   11 ++
 include/linux/mm_types.h               |    2 
 include/linux/mman.h                   |   14 +++
 include/linux/syscalls.h               |    5 +
 include/uapi/asm-generic/mman-common.h |    5 +
 include/uapi/asm-generic/unistd.h      |    5 +
 init/Kconfig                           |    9 +-
 kernel/fork.c                          |    5 +
 kernel/sys_ni.c                        |    2 
 mm/huge_memory.c                       |   30 ++++--
 mm/memory.c                            |  165 +++++++++++++++++++++-----------
 mm/mmap.c                              |  154 ++++++++++++++++++++++++++----
 mm/mremap.c                            |    4 -
 mm/process_vm_access.c                 |   71 ++++++++++++++
 17 files changed, 392 insertions(+), 99 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

