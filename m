Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2375C6B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 08:32:34 -0500 (EST)
Received: by wicr5 with SMTP id r5so750677wic.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 05:32:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120112112826.f4a8acea.kamezawa.hiroyu@jp.fujitsu.com>
References: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
	<20120112112826.f4a8acea.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 Jan 2012 21:32:32 +0800
Message-ID: <CAJd=RBBMxr+9=hT5_v4yn7RwHOwVKUK42GzaHU3KyDqJ0SsW_w@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: deactivate isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 12, 2012 at 10:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 11 Jan 2012 20:45:07 +0800
> Hillf Danton <dhillf@gmail.com> wrote:
>
>> Spinners on other CPUs, if any, could take the lru lock and do their jobs while
>> isolated pages are deactivated on the current CPU if the lock is released
>> actively. And no risk of race raised as pages are already queued on locally
>> private list.
>>
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>
> Doesn't this increase the number of lock/unlock ?
> Hmm, isn't it better to integrate clear_active_flags to isolate_pages() ?
> Then we don't need list scan.
>
Look at it soon.

Thanks,
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
