Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DCFF6B024D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 22:30:38 -0400 (EDT)
Date: Tue, 27 Jul 2010 22:30:27 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC][PATCH 2/7][memcg] cgroup arbitarary ID allocation
Message-ID: <20100728023027.GD12642@redhat.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 04:54:17PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When a subsystem want to make use of "id" more, it's necessary to
> manage the id at cgroup subsystem creation time. But, now,
> because of the order of cgroup creation callback, subsystem can't
> declare the id it wants. This patch allows subsystem to use customized
> ID for themselves.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

[..]
> Index: mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- mmotm-2.6.35-0719.orig/Documentation/cgroups/cgroups.txt
> +++ mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
> @@ -621,6 +621,15 @@ and root cgroup. Currently this will onl
>  the default hierarchy (which never has sub-cgroups) and a hierarchy
>  that is being created/destroyed (and hence has no sub-cgroups).
>  
> +void custom_id(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +
> +Called at assigning a new ID to cgroup subsystem state struct. This
> +is called when ss->use_id == true. If this function is not provided,
> +a new ID is automatically assigned. If you enable ss->use_id,
> +you can use css_lookup()  and css_get_next() to access "css" objects
> +via IDs.
> +

Couple of lines to explain why a subsystem would like to assign its
own ids and not be happy with generic cgroup assigned id be helpful.
In this case, I think you are using this id as index into array
and want to control the index, hence you seem to be doing it.

But I am not sure again why do you want to control index?

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
