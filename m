Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 405106B0092
	for <linux-mm@kvack.org>; Tue, 28 May 2013 21:42:51 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id fs12so8137280lab.35
        for <linux-mm@kvack.org>; Tue, 28 May 2013 18:42:49 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 May 2013 18:42:28 -0700
Message-ID: <CALCETrV-6_Uk=OMc6XZv61tFCKgAM77TzNs21FeOXExavUoSiw@mail.gmail.com>
Subject: SIGBUS accessing MAP_HUGETLB space w/ nr_overcommit == 0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I switched a system from Linux 3.5 to 3.9.4, and I have some crashes
that I didn't have before.  The cause is a SIGBUS w/ code BUS_ADRERR
on what I presume is the first access to a MAP_HUGETLB | MAP_PRIVATE
page.  I have nr_overcommit_hugepages == 0, so this shouldn't happen.
There are no kernel log messages at all.

Is there possibly a regression here?  Nothing seems to be asserting
any invariants with respect to the freelist size and the number of
accounted free hugepages.

I do not have CONFIG_CGROUP_HUGETLB set.

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
