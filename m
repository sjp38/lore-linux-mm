Date: Sun, 29 Sep 2002 23:55:04 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATH] slab cleanup
Message-ID: <732392454.1033343702@[10.10.2.3]>
In-Reply-To: <3D96F559.2070502@colorfullife.com>
References: <3D96F559.2070502@colorfullife.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, lse-tech@lists.sourceforge.net
Cc: akpm@digeo.com, tomlins@cam.org, "Kamble, Nitin A" <nitin.a.kamble@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Could someone test that it works on real SMP?

Tested on 16-way NUMA-Q (shows up races quicker than anything ;-)). 
Boots, compiles the kernel 5 times OK. That's good enough for me. 
No performance regression, in fact was marginally faster (within 
experimental error though).

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
