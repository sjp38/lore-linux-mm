Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5277F6B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 16:10:12 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p43KA9Kk013521
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:10:09 -0700
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by wpaz24.hot.corp.google.com with ESMTP id p43KA8Cc007979
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:10:08 -0700
Received: by gxk10 with SMTP id 10so242252gxk.11
        for <linux-mm@kvack.org>; Tue, 03 May 2011 13:10:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DC0483F.50609@redhat.com>
References: <1304444135-14128-1-git-send-email-yinghan@google.com>
	<4DC0483F.50609@redhat.com>
Date: Tue, 3 May 2011 13:10:08 -0700
Message-ID: <BANLkTinitqs6VwZyon=ew3-GhWqc6m5sUw@mail.gmail.com>
Subject: Re: [PATCH] Eliminate task stack trace duplication.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Salman Qazi <sqazi@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, May 3, 2011 at 11:23 AM, Rik van Riel <riel@redhat.com> wrote:
> On 05/03/2011 01:35 PM, Ying Han wrote:
>>
>> The problem with small dmesg ring buffer like 512k is that only limited
>> number
>> of task traces will be logged. Sometimes we lose important information
>> only
>> because of too many duplicated stack traces.
>
> I like it. =A0I often overlook information from staring
> myself blind on way too many duplicate stack traces.
>
>> This patch tries to reduce the duplication of task stack trace in the du=
mp
>> message by hashing the task stack. The hashtable is a 32k pre-allocated
>> buffer
>> during bootup.
>
> This changelog doesn't tell the whole story of what
> the code does.

Thanks Rik for reviewing it. I can add more details to the changelog .

--Ying

>
> It appears to store stack traces in the table, and
> use the hash to look them up. Somehow there's a global
> pointer, called cur_stack, involved too.
>
> The code looks correct, but somehow I'm not happy with
> it. Having said that, I also don't have ideas on how to
> make it better.
>
> If nobody else knows how to make this code better, maybe
> it should just be merged as is. I hope someone has ideas,
> though :)
>
> --
> All rights reversed
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
