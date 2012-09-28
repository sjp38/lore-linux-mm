Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 9D5A66B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:26:26 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4625017vbk.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:26:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50654F6E.7090000@cn.fujitsu.com>
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com>
 <1348728470-5580-3-git-send-email-laijs@cn.fujitsu.com> <5064CD7F.1040507@gmail.com>
 <0000013a09dec004-497e7afa-8c0f-46ff-bf8e-056f7df1ed0b-000000@email.amazonses.com>
 <50654F6E.7090000@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 28 Sep 2012 18:26:05 -0400
Message-ID: <CAHGf_=pUMDm2M2wGvnsqrDgnhj0oHUO4JVuG=u3Qcn3TLvGRgg@mail.gmail.com>
Subject: Re: [PATCH 2/3] slub, hotplug: ignore unrelated node's hot-adding and hot-removing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Christoph <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Sep 28, 2012 at 3:19 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> HI, Christoph, KOSAKI
>
> SLAB always allocates kmem_list3 for all nodes(N_HIGH_MEMORY), also node bug/bad things happens.
> SLUB always requires kmem_cache_node on the correct node, so these fix is needed.
>
> SLAB uses for_each_online_node() to travel nodes and do maintain,
> and it tolerates kmem_list3 on alien nodes.
> SLUB uses for_each_node_state(node, N_NORMAL_MEMORY) to travel nodes and do maintain,
> and it does not tolerate kmem_cache_node on alien nodes.
>
> Maybe we need to change SLAB future and let it use
> for_each_node_state(node, N_NORMAL_MEMORY), But I don't want to change SLAB
> until I find something bad in SLAB.

SLAB can't use highmem. then traverse zones which don't have normal
memory is silly IMHO.
If this is not bug, current slub behavior is also not bug. Is there
any difference?

If I understand correctly, current code may waste some additional
memory on corner case. but it doesn't make memory leak both when slab
and slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
