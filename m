Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3282E6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 18:33:26 -0500 (EST)
Date: Wed, 9 Jan 2013 15:33:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
Message-Id: <20130109153324.bbd019b3.akpm@linux-foundation.org>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:24 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> This patch-set aims to implement physical memory hot-removing.

As you were on th patch delivery path, all of these patches should have
your Signed-off-by:.  But some were missing it.  I fixed this in my
copy of the patches.


I suspect this patchset adds a significant amount of code which will
not be used if CONFIG_MEMORY_HOTPLUG=n.  "[PATCH v6 06/15]
memory-hotplug: implement register_page_bootmem_info_section of
sparse-vmemmap", for example.  This is not a good thing, so please go
through the patchset (in fact, go through all the memhotplug code) and
let's see if we can reduce the bloat for CONFIG_MEMORY_HOTPLUG=n
kernels.

This needn't be done immediately - it would be OK by me if you were to
defer this exercise until all the new memhotplug code is largely in
place.  But please, let's do it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
