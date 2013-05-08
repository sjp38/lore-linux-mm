Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9AAC26B0070
	for <linux-mm@kvack.org>; Wed,  8 May 2013 19:35:29 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 8 May 2013 19:35:28 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4AF006E8047
	for <linux-mm@kvack.org>; Wed,  8 May 2013 19:35:23 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r48NZQT3302422
	for <linux-mm@kvack.org>; Wed, 8 May 2013 19:35:26 -0400
Received: from d01av05.pok.ibm.com (loopback [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r48NZO38011551
	for <linux-mm@kvack.org>; Wed, 8 May 2013 19:35:26 -0400
Message-ID: <518AE13A.2060204@linux.vnet.ibm.com>
Date: Wed, 08 May 2013 16:35:22 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5, part4 20/41] mm/h8300: prepare for removing num_physpages
 and simplify mem_init()
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com> <1368028298-7401-21-git-send-email-jiang.liu@huawei.com> <518A7CC0.1010606@cogentembedded.com> <518AA7A0.1020702@cogentembedded.com>
In-Reply-To: <518AA7A0.1020702@cogentembedded.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Geert Uytterhoeven <geert@linux-m68k.org>

On 05/08/2013 12:29 PM, Sergei Shtylyov wrote:
>
>      Although, not necessarily: it also supports CONFIG_DYNAMIC_DEBUG --
> look at how pr_debug() is defined.
> So this doesn't seem to be an equivalent change, and I suggest not doing
> it at all.
>
> WBR, Sergei

pr_devel() should get the same behavior: no code emitted unless debug is 
defined, if it is, output at KERN_DEBUG level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
