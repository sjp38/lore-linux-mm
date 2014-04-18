Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D542A6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:18:31 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so1740520pdb.14
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:18:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id c7si15545275pay.150.2014.04.18.13.18.30
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 13:18:30 -0700 (PDT)
Date: Fri, 18 Apr 2014 13:18:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2 1/2] mem-hotplug: implement get/put_online_mems
Message-Id: <20140418131828.804a181e5b4364a704d786cc@linux-foundation.org>
In-Reply-To: <b65ff63d5805c86fa288bc09db4f378492c6c543.1396857765.git.vdavydov@parallels.com>
References: <cover.1396857765.git.vdavydov@parallels.com>
	<b65ff63d5805c86fa288bc09db4f378492c6c543.1396857765.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <liuj97@gmail.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>

On Mon, 7 Apr 2014 13:45:34 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> {un}lock_memory_hotplug, which is used to synchronize against memory
> hotplug, is currently backed by a mutex, which makes it a bit of a
> hammer - threads that only want to get a stable value of online nodes
> mask won't be able to proceed concurrently. Also, it imposes some strong
> locking ordering rules on it, which narrows down the set of its usage
> scenarios.
> 
> This patch introduces get/put_online_mems, which are the same as
> get/put_online_cpus, but for memory hotplug, i.e. executing a code
> inside a get/put_online_mems section will guarantee a stable value of
> online nodes, present pages, etc.

Well that seems a nice change.  I added the important paragraph

"lock_memory_hotplug()/unlock_memory_hotplug() are removed altogether."

I'll Cc a large number of people who have recently worked on the memory
hotplug code.  Hopefully some of them will have time to review and test
these patches, thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
