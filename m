Date: Thu, 3 May 2007 19:42:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmmmm... I do not see a regression (up to date slub with all outstanding 
patches applied). This is without any options enabled (but antifrag 
patches are present so slub_max_order=4 slub_min_objects=16) Could you 
post a .config? Missing patches against 2.6.21-rc7-mm2 can be found at 
http://ftp.kernel.org/pub/linux/kernel/peopl/christoph/slub-patches

slab

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost 
(127.0.0.1) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.01    6068.61
 87380  16384  16384    10.01    5877.91
 87380  16384  16384    10.01    5835.68
 87380  16384  16384    10.01    5840.58

slub

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.53    5646.53
 87380  16384  16384    10.01    6073.09
 87380  16384  16384    10.01    6094.68
 87380  16384  16384    10.01    6088.50


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
