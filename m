Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 099D86B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 01:46:53 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so6675097pde.38
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 22:46:53 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id d17so3179061eek.28
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 22:46:50 -0700 (PDT)
Date: Tue, 1 Oct 2013 07:46:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] mm, memory-hotpulg: Rename movablenode boot option
 to movable_node
Message-ID: <20131001054646.GA17220@gmail.com>
References: <5249B7C6.7010902@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5249B7C6.7010902@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, imtangchen@gmail.com


* Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:

> @@ -153,11 +153,18 @@ config MOVABLE_NODE
>  	help
>  	  Allow a node to have only movable memory.  Pages used by the kernel,
>  	  such as direct mapping pages cannot be migrated.  So the corresponding
> +	  memory device cannot be hotplugged.  This option allows the following
> +	  two things:
> +	  - When the system is booting, node full of hotpluggable memory can
> +	  be arranged to have only movable memory so that the whole node can
> +	  be hotplugged. (need movable_node boot option specified).

So this is _exactly_ what I complained about earlier: why is the 
movable_node boot option needed to get that extra functionality? It's 
clearly not just a drop-in substitute to CONFIG_MOVABLE_NODE but extends 
its functionality, right?

Boot options are _very_ poor user interface. If you don't want to enable 
it by default then turn this sub-functionality into 
CONFIG_MOVABLE_NODE_AUTO and keep it default-off - but don't pretend that 
this is only about CONFIG_MOVABLE_NODE alone - it isnt: as described above 
the 'movable_node' is needed for the full functionality to be available!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
