Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 78FD66B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 03:40:51 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CCBBF3EE0C0
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:40:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B188645DEC0
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:40:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9645845DEB7
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:40:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 814B21DB804A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:40:49 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 345261DB8042
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:40:49 +0900 (JST)
Message-ID: <50EE7E5A.9090402@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 17:39:54 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com> <50EE6A48.7060307@parallels.com> <50EE6E50.3040609@jp.fujitsu.com> <50EE73DE.30208@parallels.com> <50EE7A6B.7020005@jp.fujitsu.com> <50EE7D75.8080100@parallels.com>
In-Reply-To: <50EE7D75.8080100@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2013/01/10 17:36), Glauber Costa wrote:
  
>> BTW, shrink_slab() is now node/zone aware ? If not, fixing that first will
>> be better direction I guess.
>>
> It is not upstream, but there are patches for this that I am already
> using in my private tree.
>

Oh, I see. If it's merged, it's worth add "shrink_slab() if ZONE_NORMAL"
code.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
