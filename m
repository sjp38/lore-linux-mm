Subject: Regression with SLUB on Netperf and Volanomark
From: Tim Chen <tim.c.chen@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
Content-Type: text/plain
Date: Wed, 02 May 2007 11:43:29 -0700
Message-Id: <1178131409.23795.160.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: suresh.b.siddha@intel.com, yanmin.zhang@intel.com, peter.xihong.wang@intel.com, arjan.van.de.ven@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph,

We tested SLUB on a 2 socket Clovertown (Core 2 cpu with 2 cores/socket)
and a 2 socket Woodcrest (Core2 cpu with 4 cores/socket).  

We found that for Netperf's TCP streaming tests in a loop back mode, the
TCP streaming performance is about 7% worse when SLUB is enabled on
2.6.21-rc7-mm1 kernel (x86_64).  This test have a lot of sk_buff
allocation/deallocation.

For Volanomark, the performance is 7% worse for Woodcrest and 12% worse
for Clovertown.

Regards,
Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
