Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B33F36B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:03:20 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oAUM1pAP006863
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:01:51 -0800
Received: from qwg5 (qwg5.prod.google.com [10.241.194.133])
	by hpaq3.eem.corp.google.com with ESMTP id oAUM0mtY009841
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:01:49 -0800
Received: by qwg5 with SMTP id 5so4989353qwg.17
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:01:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130170753.dddf1121.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
	<20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
	<20101130170753.dddf1121.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 14:01:48 -0800
Message-ID: <AANLkTi=v1_bDmZ1YE6h_AuhhgLyF5dr2WAuku3mZ09od@mail.gmail.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 12:07 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Nov 2010 16:51:42 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> > + =A0 =A0 =A0 =A0 =A0 if (IS_ERR(thr))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "Failed to star=
t kswapd on memcg %d\n",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0);
>> > + =A0 =A0 =A0 =A0 =A0 else
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p->kswapd_task =3D thr;
>> > + =A0 }
>>
>> Hmm, ok, then, kswapd-for-memcg is created when someone go over watermar=
k.
>> Why this new kswapd will not exit() until memcg destroy ?
>>
>> I think there are several approaches.
>>
>> =A0 1. create/destroy a thread at memcg create/destroy
>> =A0 2. create/destroy a thread at watermarks.
>> =A0 3. use thread pool for watermarks.
>> =A0 4. use workqueue for watermaks.
>>
>> The good point of "1" is that we can control a-thread-for-kswapd by cpu
>> controller but it will use some resource.
>> The good point of "2" is that we can avoid unnecessary resource usage.
>>
>> 3 and 4 is not very good, I think.
>>
>> I'd like to vote for "1"...I want to avoid "stealing" other container's =
cpu
>> by bad application in a container uses up memory.
>>
>
> One more point, one-thread-per-hierarchy is enough. So, please check
> memory.use_hierarchy=3D=3D1 or not at creating a thread.

Thanks. Will take a look at it.

--Ying
>
> Thanks,
> -kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
