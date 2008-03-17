Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m2H1u0cV016736
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:56:01 -0700
Received: from py-out-1112.google.com (pybu77.prod.google.com [10.34.97.77])
	by zps36.corp.google.com with ESMTP id m2H1txj4010384
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:56:00 -0700
Received: by py-out-1112.google.com with SMTP id u77so5246843pyb.16
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:55:59 -0700 (PDT)
Message-ID: <6599ad830803161855y1ceb8aa8t2f486434b521bd81@mail.gmail.com>
Date: Mon, 17 Mar 2008 09:55:59 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
In-Reply-To: <47DDCE5E.9020104@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
	 <47DDCE5E.9020104@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 9:50 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I am yet to measure the performance overhead of the accounting checks. I'll try
>  and get started on that today. I did not consider making it a separate system,
>  because I suspect that anybody wanting memory control would also want address
>  space control (for the advantages listed in the documentation).

I'm a counter-example to your suspicion :-)

Trying to control virtual address space is a complete nightmare in the
presence of anything that uses large sparsely-populated mappings
(mmaps of large files, or large sparse heaps such as the JVM uses.)

If we want to control the effect of swapping, the right way to do it
is to control disk I/O, and ensure that the swapping is accounted to
that. Or simply just not give apps much swap space.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
