From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [rfc] SLQB: YASA
Date: Thu, 03 Apr 2008 10:41:13 +0200
Message-ID: <87r6dns53q.fsf@basil.nowhere.org>
References: <84144f020804030045p44456894lfc006dcdeab6f67c@mail.gmail.com>
	<20080403075725.GA7514@wotan.suse.de>
	<20080403171626.0283.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080403082650.GA20132@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761921AbYDCIl1@vger.kernel.org>
In-Reply-To: <20080403082650.GA20132@wotan.suse.de> (Nick Piggin's message of "Thu, 3 Apr 2008 10:26:51 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

Nick Piggin <npiggin@suse.de> writes:
>
> Nothing really interesting, unfortunately. I have run some tests on
> various microbenchmarks like tbench and things like that. But I
> don't have many good ideas for more meaningful tests where slab
> allocation performance is critial. Any suggestions? :)

Some networking workloads hit slab pretty aggressive (two 
allocations per packet) 

Just be careful with standard loopback, it has a contended lock
elsewhere

-Andi
