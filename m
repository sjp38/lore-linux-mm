Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 63ED86B0034
	for <linux-mm@kvack.org>; Sun, 12 May 2013 11:17:23 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so3828158pde.32
        for <linux-mm@kvack.org>; Sun, 12 May 2013 08:17:22 -0700 (PDT)
Message-ID: <518FB27A.4070903@gmail.com>
Date: Sun, 12 May 2013 23:17:14 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5, part4 20/41] mm/h8300: prepare for removing num_physpages
 and simplify mem_init()
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com> <1368028298-7401-21-git-send-email-jiang.liu@huawei.com> <518A7CC0.1010606@cogentembedded.com> <518AA7A0.1020702@cogentembedded.com> <518AE13A.2060204@linux.vnet.ibm.com>
In-Reply-To: <518AE13A.2060204@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Geert Uytterhoeven <geert@linux-m68k.org>

On 05/09/2013 07:35 AM, Cody P Schafer wrote:
> On 05/08/2013 12:29 PM, Sergei Shtylyov wrote:
>>
>>      Although, not necessarily: it also supports CONFIG_DYNAMIC_DEBUG --
>> look at how pr_debug() is defined.
>> So this doesn't seem to be an equivalent change, and I suggest not doing
>> it at all.
>>
>> WBR, Sergei
>
> pr_devel() should get the same behavior: no code emitted unless debug 
> is defined, if it is, output at KERN_DEBUG level.
>
Thanks Cody and Sergei, will use pr_devel() instead in next version.
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
