From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Tue, 08 Apr 2008 12:22:29 +0530
Message-ID: <47FB162D.1020506@linux.vnet.ibm.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain> <47F5F3FA.7060709@linux.vnet.ibm.com> <6599ad830804041211r37848a6coaa900d8bdac40fbe@mail.gmail.com> <47F79102.6090406@linux.vnet.ibm.com> <6599ad830804051023v69caa3d4h6e26ccb420bca899@mail.gmail.com> <47F7BB69.3000502@linux.vnet.ibm.com> <6599ad830804051057n2f2802e4w6179f2e108467494@mail.gmail.com> <47F7CC08.4090209@linux.vnet.ibm.com> <6599ad830804051629k3649dbc4na92bb3d0cd7a0492@mail.gmail.com> <47F861C8.7080700@linux.vnet.ibm.com> <6599ad830804072337g2e7b4613hdcc05062dc2ca4e0@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753823AbYDHGyR@vger.kernel.org>
In-Reply-To: <6599ad830804072337g2e7b4613hdcc05062dc2ca4e0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Sat, Apr 5, 2008 at 10:38 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >
>>  > How long does the test run for? How many threads does each client have?
>>
>>  The test on each client side runs for about 10 seconds. I saw the client create
>>  up to 411 threads.
>>
> 
> I'm not convinced that an application that creates 400 threads and
> exits in 10 seconds is particular representative of a high-performance
> application.
> 

I agree, but like I said earlier, this was the easily available ready made
application I found. Do you know of any other highly threaded micro benchmark?

> But I agree that it's an example of something it may be worth trying
> to optimize for.
> 
> You mention that you saw tgid exits - what order did the individual
> threads exit in? If we threw the mm to the last thread in the thread
> group rather than the first, would that help?

The order was different each time. I suspect that when we have too many threads
all exiting at once and they are all running in parallel, I don't know if we can
have ordering or predict the order in which threads exit.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
