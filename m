Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k72KwCH4003999
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 16:58:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k72Kw9KT285346
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 16:58:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k72Kw8Vu032698
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 16:58:08 -0400
Subject: Re: [RFC][PATCH] enable VMSPLIT for highmem kernels
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060802205533.CBD06E21@localhost.localdomain>
References: <20060802205533.CBD06E21@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 02 Aug 2006 13:57:56 -0700
Message-Id: <1154552277.7232.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Well, I somehow managed to post that without appending my description.
Here goes:

The current VMSPLIT Kconfig option is disabled whenever highmem
is on.  This is a bit screwy because the people who need to
change VMSPLIT the most tend to be the ones with highmem and
constrained lowmem.

So, remove the highmem dependency.  But, re-include the
dependency for the "full 1GB of lowmem" option.  You can't have
the full 1GB of lowmem and highmem because of the need for the
vmalloc(), kmap(), etc... areas.

I thought there would be at least a bit of tweaking to do to
get it to work, but everything seems OK.

Boot tested on a 4GB x86 machine, and a 12GB 3-node NUMA-Q:

elm3b82:~# cat /proc/meminfo
MemTotal:      3695412 kB
MemFree:       3659540 kB
...
LowTotal:      2909008 kB
LowFree:       2892324 kB
...
elm3b82:~# zgrep PAE /proc/config.gz
CONFIG_X86_PAE=y

larry:~# cat /proc/meminfo
MemTotal:     11845900 kB
MemFree:      11786748 kB
...
LowTotal:      2855180 kB
LowFree:       2830092 kB

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
