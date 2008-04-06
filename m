From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Sun, 06 Apr 2008 12:01:43 +0530
Message-ID: <47F86E4F.2080103@linux.vnet.ibm.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain> <47F5E69C.9@linux.vnet.ibm.com> <6599ad830804040150j4946cf92h886bb26000319f3b@mail.gmail.com> <47F5F3FA.7060709@linux.vnet.ibm.com> <6599ad830804041211r37848a6coaa900d8bdac40fbe@mail.gmail.com> <47F79102.6090406@linux.vnet.ibm.com> <6599ad830804051023v69caa3d4h6e26ccb420bca899@mail.gmail.com> <47F7BB69.3000502@linux.vnet.ibm.com> <6599ad830804051057n2f2802e4w6179f2e108467494@mail.gmail.com> <47F7CC08.4090209@linux.vnet.ibm.com> <6599ad830804051631g15363456s1952fda0bb4d395d@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755546AbYDFGcv@vger.kernel.org>
In-Reply-To: <6599ad830804051631g15363456s1952fda0bb4d395d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Sat, Apr 5, 2008 at 11:59 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >>  It's easier to set it up that way. Usually the end user gets the same SLA for
>>  >>  memory, CPU and other resources, so it makes sense to bind the controllers together.
>>  >>
>>  >
>>  > True - but in that case why wouldn't they have the same SLA for
>>  > virtual address space too?
>>  >
>>
>>  Yes, mostly. That's why I had made the virtual address space patches as a config
>>  option on top of the memory controller :)
>>
> 
> *If* they want to use the virtual address space controller, that is.
> 
> By that argument, you should make the memory and cpu controllers the
> same controller, since in your scenario they'll usually be used
> together..

Heh, Virtual address and memory are more closely interlinked than CPU and Memory.
-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
