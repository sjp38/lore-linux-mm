Received: from krystal.dyndns.org ([76.65.100.197])
          by tomts20-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070710205902.OGFH1637.tomts20-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Tue, 10 Jul 2007 16:59:02 -0400
Date: Tue, 10 Jul 2007 16:59:01 -0400
From: Mathieu Desnoyers <compudj@krystal.dyndns.org>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance and maintenance
Message-ID: <20070710205901.GA19805@Krystal>
References: <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal> <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com> <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com> <20070710082709.GC16148@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8BIT
In-Reply-To: <20070710082709.GC16148@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Alexandre =?iso-8859-1?Q?Gu=E9don?= <totalworlddomination@gmail.com>
List-ID: <linux-mm.kvack.org>

Another architecture tested

Comparison: irq enable/disable vs local CMPXCHG
             enable interrupts (STI)   disable interrupts (CLI)    local CMPXCHG
Tested-by: Mathieu Desnoyers <compudj@krystal.dyndns.org>
IA32 (P4)               112                        82                       26
x86_64 AMD64            125                       102                       19
Tested-by: Alexandre Guedon <totalworlddomination@gmail.com>
x86_64 Intel Core2 Quad  21                        19                        7


-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
