Date: Tue, 11 Mar 2008 19:03:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Message-Id: <20080311190318.6b4bd394.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47D65680.4090106@linux.vnet.ibm.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
	<6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
	<20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com>
	<47D64E0A.3090907@linux.vnet.ibm.com>
	<20080311183940.11695e41.kamezawa.hiroyu@jp.fujitsu.com>
	<47D65680.4090106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 15:23:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > But if you'd like to add relationship between virtual-limit/memory-usage-limit,
> > please take care to make it clear that relationship is reaseonable.
> > 
> 
> No, I don't want to add a relationship, just plain virtual memory limits and let
> the system administrators determine what works for them.
> 
ok :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
