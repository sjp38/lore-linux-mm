Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1146B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 15:20:07 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id c9so8142102qcz.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:20:07 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id h45si3284582qgd.59.2015.01.23.12.20.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 12:20:06 -0800 (PST)
Date: Fri, 23 Jan 2015 14:20:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
In-Reply-To: <20150123141817.GA22926@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.11.1501231419420.11767@gentwo.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Fri, 23 Jan 2015, Johannes Weiner wrote:

>         struct mem_cgroup_tree_per_node *rtpn;
>         struct mem_cgroup_tree_per_zone *rtpz;
> -       int tmp, node, zone;
> +       int node, zone;
>
>         for_each_node(node) {

Do for_each_online_node(node) {

instead?

> -               tmp = node;
> -               if (!node_state(node, N_NORMAL_MEMORY))
> -                       tmp = -1;
> -               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
> +               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
>                 BUG_ON(!rtpn);
>
>                 soft_limit_tree.rb_tree_per_node[node] = rtpn;
>
> --
>
> Is the assumption of this patch wrong?  Does the specified node have
> to be online for the fallback to work?
>
> Thanks
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
