Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 712B46B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 06:19:07 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so3756957pbc.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 03:19:06 -0800 (PST)
Date: Mon, 17 Dec 2012 03:19:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] memory-hotplug: Disable CONFIG_MOVABLE_NODE option
 by default.
In-Reply-To: <1355708488-2913-3-git-send-email-tangchen@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1212170318110.21139@chino.kir.corp.google.com>
References: <1355708488-2913-1-git-send-email-tangchen@cn.fujitsu.com> <1355708488-2913-3-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, mingo@elte.hu, penberg@kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Dec 2012, Tang Chen wrote:

> This patch set CONFIG_MOVABLE_NODE to "default n" instead of
> "depends on BROKEN".
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

It's fine to change the default, but what's missing here is a rationale 
for no longer making it depend on CONFIG_BROKEN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
