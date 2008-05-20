Message-ID: <4832987A.2070801@openvz.org>
Date: Tue, 20 May 2008 13:23:06 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com> <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Does anyone have a better idea ?
> ==
>  
> Currently, cgroup's seq_file interface just supports single_open.
> This patch allows arbitrary seq_ops if passed.

That's great :)

> For example, "status per cpu, status per node" can be very big
> in general and they tend to use its own start/next/stop ops.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
