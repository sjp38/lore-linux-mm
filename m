Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3EE956B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:36:46 -0400 (EDT)
Message-ID: <520E5517.9070606@intel.com>
Date: Fri, 16 Aug 2013 09:36:39 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: hpa@zytor.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

Hey Nathan,

Could you post your boot timing patches?  My machines are much smaller
than yours, but I'm curious how things behave here as well.

I did some very imprecise timings (strace -t on a telnet attached to the
serial console).  The 'struct page' initializations take about a minute
of boot time for me to do 1TB across 8 NUMA nodes (this is a glueless
QPI system[1]).  My _quick_ calculations look like it's 2x as fast to
initialize node0's memory vs. the other nodes, and boot time is
increased by a second for about every 30G of memory we add.

So even with nothing else fancy, we could get some serious improvements
from just doing the initialization locally.

[1] We call anything using pure QPI without any other circuitry for the
NUMA interconnects to be "glueless"

	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
