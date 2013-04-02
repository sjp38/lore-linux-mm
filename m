Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id DE77C6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 03:24:53 -0400 (EDT)
Message-ID: <515A87C3.1000309@profihost.ag>
Date: Tue, 02 Apr 2013 09:24:51 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: NUMA Autobalancing Kernel 3.8
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

Hello list,

i was trying to play with the new NUMA autobalancing feature of Kernel 3.8.

But if i enable:
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_NUMA_BALANCING=y

i see random process crashes mostly in libc using vanilla 3.8.4.

Greets,
Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
