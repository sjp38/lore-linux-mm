Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14CE36B025F
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 17:23:04 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a107so879771wrc.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 14:23:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a26si800602wrd.396.2017.12.05.14.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 14:23:03 -0800 (PST)
Date: Tue, 5 Dec 2017 14:23:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v3 0/7] ktask: multithread CPU-intensive kernel work
Message-Id: <20171205142300.67489b1a90605e1089c5aaa9@linux-foundation.org>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On Tue,  5 Dec 2017 14:52:13 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> This patchset is based on 4.15-rc2 plus one mmots fix[*] and contains three
> ktask users:
>  - deferred struct page initialization at boot time
>  - clearing gigantic pages
>  - fallocate for HugeTLB pages

Performance improvements are nice.  How much overall impact is there in
real-world worklaods?

> Work in progress:
>  - Parallelizing page freeing in the exit/munmap paths

Also sounds interesting.  Have you identified any other parallelizable
operations?  vfs object teardown at umount time may be one...

>  - CPU hotplug support

Of what?  The ktask infrastructure itself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
