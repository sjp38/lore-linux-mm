Date: Mon, 1 Sep 2008 15:24:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080901152424.d9adfe47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BB8716.5090805@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<20080901090102.46b75141.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB6160.4070904@linux.vnet.ibm.com>
	<20080901130351.f005d5b6.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB8716.5090805@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 01 Sep 2008 11:39:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:


> > The development of lockless-page_cgroup is not stalled. I'm just waiting for
> > my 8cpu box comes back from maintainance...
> > If you want to see, I'll post v3 with brief result on small (2cpu) box.
> > 
> 
> I understand and I am not pushing you to completing it, but at the same time I
> don't want to queue up behind it for long. I suspect the cost of porting
> lockless page cache on top of my patches should not be high, but I'll never know
> till I try :)
> 
My point is, your patch adds big lock. Then, I don't have to do meaningless effort
to reduce lock.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
