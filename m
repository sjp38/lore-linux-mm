Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B1D576B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:51:00 -0400 (EDT)
Received: by gxk28 with SMTP id 28so938553gxk.14
        for <linux-mm@kvack.org>; Tue, 09 Jun 2009 01:19:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090609164850.DD73.A69D9226@jp.fujitsu.com>
References: <20090609161925.DD70.A69D9226@jp.fujitsu.com>
	 <28c262360906090048x792fb3f9i6678298b693f6c5a@mail.gmail.com>
	 <20090609164850.DD73.A69D9226@jp.fujitsu.com>
Date: Tue, 9 Jun 2009 17:19:20 +0900
Message-ID: <28c262360906090119r6e881caq9b74028ba43567a7@mail.gmail.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH
	mmotm] vmscan: fix may_swap handling for memcg)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 9, 2009 at 4:58 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, KOSAKI.
>>
>> As you know, this problem caused by if condition(priority) in shrink_zone.
>> Let me have a question.
>>
>> Why do we have to prevent scan value calculation when the priority is zero ?
>> As I know, before split-lru, we didn't do it.
>>
>> Is there any specific issue in case of the priority is zero ?
>
> Yes.
>
> example:
>
> get_scan_ratio() return anon:80%, file=20%. and the system have
> 10000 anon pages and 10000 file pages.
>
> shrink_zone() picked up 8000 anon pages and 2000 file pages.
> it mean 8000 file pages aren't scanned at all.
>
> Oops, it can makes OOM-killer although system have droppable file cache.
>
Hmm..Can that problem be happen in real system ?
The file ratio is big means that file lru list scanning is so big but
rotate is small.
It means file lru have few reclaimable page.

Isn't it ? I am confusing.
Could you elaborate, please if you don't mind ?

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
