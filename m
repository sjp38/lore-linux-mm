Date: Tue, 21 Feb 2006 18:33:06 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] remove zone_mem_map
Message-Id: <20060221183306.3d467d14.akpm@osdl.org>
In-Reply-To: <43FBAEBA.2020300@jp.fujitsu.com>
References: <43FBAEBA.2020300@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haveblue@us.ibm.com, Christoph Lameter <christoph@lameter.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> This patch removes zone_mem_map from zone.
>  By this, (generic) page_to_pfn and pfn_to_page can use the same logic.

I assume this is dependent upon unify-pfn_to_page-*.patch?

>  This modifies page_to_pfn implementation. Could anyone do performance test on NUMA ?

Do you expect there to be NUMA performance problems?  If so, how do they
arise and what sort of tests should be run?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
