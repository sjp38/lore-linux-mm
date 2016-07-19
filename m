Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D15356B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 14:50:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p64so53462905pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 11:50:22 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id jx11si2901117pad.273.2016.07.19.11.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 11:50:22 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id ez1so1771078pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 11:50:22 -0700 (PDT)
Date: Tue, 19 Jul 2016 14:50:17 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v8 1/7] x86, memhp, numa: Online memory-less nodes at
 boot time.
Message-ID: <20160719185017.GM3078@mtj.duckdns.org>
References: <1468913288-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1468913288-16605-2-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468913288-16605-2-git-send-email-douly.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

Hello,

On Tue, Jul 19, 2016 at 03:28:02PM +0800, Dou Liyang wrote:
> In this series of patches, we are going to construct cpu <-> node mapping
> for all possible cpus at boot time, which is a 1-1 mapping. It means the

1-1 mapping means that each cpu is mapped to its own private node
which isn't the case.  Just call it a persistent mapping?

> cpu will be mapped to the node it belongs to, and will never be changed.
> If a node has only cpus but no memory, the cpus on it will be mapped to
> a memory-less node. And the memory-less node should be onlined.
> 
> This patch allocate pgdats for all memory-less nodes and online them at
> boot time. Then build zonelists for these nodes. As a result, when cpus
> on these memory-less nodes try to allocate memory from local node, it
> will automatically fall back to the proper zones in the zonelists.

Yeah, I think this is an a lot better approach for memory-less nodes.

> Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
