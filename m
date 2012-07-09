Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3873D6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:18:59 -0400 (EDT)
Date: Mon, 9 Jul 2012 10:18:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v3 0/13] memory-hotplug : hot-remove physical
 memory
In-Reply-To: <4FFAB0A2.8070304@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1207091015570.30060@router.home>
References: <4FFAB0A2.8070304@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com


On Mon, 9 Jul 2012, Yasuaki Ishimatsu wrote:

> Even if you apply these patches, you cannot remove the physical memory
> completely since these patches are still under development. I want you to
> cooperate to improve the physical memory hot-remove. So please review these
> patches and give your comment/idea.

Could you at least give a method on how you want to do physical memory
removal? You would have to remove all objects from the range you want to
physically remove. That is only possible under special circumstances and
with a limited set of objects. Even if you exclusively use ZONE_MOVEABLE
you still may get cases where pages are pinned for a long time.

I am not sure that these patches are useful unless we know where you are
going with this. If we end up with a situation where we still cannot
remove physical memory then this patchset is not helpful.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
