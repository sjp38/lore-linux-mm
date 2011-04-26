Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3405B8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:05:23 -0400 (EDT)
Received: by wwi18 with SMTP id 18so1902113wwi.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426115902.F374.A69D9226@jp.fujitsu.com>
References: <20110426025429.GA11812@darkstar>
	<20110426115902.F374.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 11:05:20 +0800
Message-ID: <BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 26, 2011 at 10:57 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> oom_killer_disable should be a global switch, also fit for oom paths
>> other than __alloc_pages_slowpath
>>
>> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.
>
> Can you please explain more? Why should? Now oom_killer_disabled is used
> only hibernation path. so, Why pagefault and memcg allocation will be happen?

Indeed I'm using it in virtio balloon test, oom killer triggered when
memory pressure is high.

literally oom_killer_disabled scope should be global, isn't it?

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
