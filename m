Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3276B0012
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:26:22 -0400 (EDT)
Received: by wyf19 with SMTP id 19so189424wyf.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:26:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426121719.95894bc5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110426115902.F374.A69D9226@jp.fujitsu.com>
	<BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
	<20110426121555.F378.A69D9226@jp.fujitsu.com>
	<BANLkTino+9_GEb28gfZYSu-R0JW44M1mqQ@mail.gmail.com>
	<20110426121719.95894bc5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 11:26:19 +0800
Message-ID: <BANLkTi=f3V8-2Fe85aooBTEYEq_Kb37Nxw@mail.gmail.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 26, 2011 at 11:17 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 Apr 2011 11:19:22 +0800
> Dave Young <hidave.darkstar@gmail.com> wrote:
>
>> On Tue, Apr 26, 2011 at 11:14 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> On Tue, Apr 26, 2011 at 10:57 AM, KOSAKI Motohiro
>> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >> oom_killer_disable should be a global switch, also fit for oom paths
>> >> >> other than __alloc_pages_slowpath
>> >> >>
>> >> >> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.
>> >> >
>> >> > Can you please explain more? Why should? Now oom_killer_disabled is used
>> >> > only hibernation path. so, Why pagefault and memcg allocation will be happen?
>> >>
>> >> Indeed I'm using it in virtio balloon test, oom killer triggered when
>> >> memory pressure is high.
>> >>
>> >> literally oom_killer_disabled scope should be global, isn't it?
>> >
>> > ok. virtio baloon seems fair usage. if you add new usage of oom_killer_disabled
>> > into the patch description, I'll ack this one.
>>
>> Thanks, then I will resend the virtio balloon patch along with this.
>>
>
> Amount of free memory doesn't affect memory cgroup's OOM because it just works
> against the limit. So, the code for memcg isn't necessary.

Right, thanks for pointing out this, will remove the memcg part
>
>
> Thanks,
> -Kame
>
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
