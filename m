Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 7BEB96B0071
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:50:33 -0500 (EST)
Date: Wed, 9 Jan 2013 14:50:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 05/15] memory-hotplug: introduce new function
 arch_remove_memory() for removing page table depends on architecture
Message-Id: <20130109145031.210505d0.akpm@linux-foundation.org>
In-Reply-To: <1357723959-5416-6-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-6-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:29 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> For removing memory, we need to remove page table. But it depends
> on architecture. So the patch introduce arch_remove_memory() for
> removing page table. Now it only calls __remove_pages().
> 
> Note: __remove_pages() for some archtecuture is not implemented
>       (I don't know how to implement it for s390).

Can this break the build for s390?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
