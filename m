Date: Wed, 5 Dec 2007 09:26:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [5/8] throttling simultaneous callers of try_to_free_mem_cgroup_pages
Message-Id: <20071205092639.1744d4c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <475555BA.7070805@linux.vnet.ibm.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203092418.58631593@bree.surriel.com>
	<20071204103332.ad4cf9b5.kamezawa.hiroyu@jp.fujitsu.com>
	<475555BA.7070805@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Dec 2007 18:57:22 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Adding this kind of controls to global memory allocator/LRU may cause
> > unexpected slow down in application's response time. High-response application
> > users may dislike this. We may need another gfp_flag or sysctl to allow
> > throttling in global.
> > For memory controller, the user sets its memory limitation by himself. He can
> > adjust parameters and the workload. So, I think this throttoling is not so
> > problematic in memory controller as global.
> > 
> > Of course, we can export "do throttoling or not" control in cgroup interface.
> > 
> 
> I think we should export the interface.
> 
Ok, I'll export.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
