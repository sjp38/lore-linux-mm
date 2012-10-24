Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3F99D6B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 09:39:03 -0400 (EDT)
Date: Wed, 24 Oct 2012 13:39:01 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2 V2] slub, hotplug: ignore unrelated node's hot-adding
 and hot-removing
In-Reply-To: <1351071840-5060-3-git-send-email-laijs@cn.fujitsu.com>
Message-ID: <0000013a92ff635f-6f359d39-eb8d-44e9-b6fc-0925a09e8da2-000000@email.amazonses.com>
References: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com> <1351071840-5060-3-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Mel Gorman <mgorman@suse.de>, 'FNST-Wen Congyang' <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Wed, 24 Oct 2012, Lai Jiangshan wrote:

> SLUB only fucus on the nodes which has normal memory, so ignore the other
> node's hot-adding and hot-removing.

As far as I can see the reasoning sounds fine and the patch looks clean.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
