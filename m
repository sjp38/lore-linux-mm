Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1489000BD
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:19:25 -0400 (EDT)
Received: by wwi36 with SMTP id 36so170859wwi.26
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:19:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426121555.F378.A69D9226@jp.fujitsu.com>
References: <20110426115902.F374.A69D9226@jp.fujitsu.com>
	<BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
	<20110426121555.F378.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 11:19:22 +0800
Message-ID: <BANLkTino+9_GEb28gfZYSu-R0JW44M1mqQ@mail.gmail.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 26, 2011 at 11:14 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, Apr 26, 2011 at 10:57 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> oom_killer_disable should be a global switch, also fit for oom paths
>> >> other than __alloc_pages_slowpath
>> >>
>> >> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.
>> >
>> > Can you please explain more? Why should? Now oom_killer_disabled is used
>> > only hibernation path. so, Why pagefault and memcg allocation will be happen?
>>
>> Indeed I'm using it in virtio balloon test, oom killer triggered when
>> memory pressure is high.
>>
>> literally oom_killer_disabled scope should be global, isn't it?
>
> ok. virtio baloon seems fair usage. if you add new usage of oom_killer_disabled
> into the patch description, I'll ack this one.

Thanks, then I will resend the virtio balloon patch along with this.

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
