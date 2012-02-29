Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0BEC76B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:31:56 -0500 (EST)
Message-ID: <4F4E60BB.9030007@parallels.com>
Date: Wed, 29 Feb 2012 14:30:35 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] small cleanup for memcontrol.c
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <1329824079-14449-2-git-send-email-glommer@parallels.com> <20120222094619.caffc432.kamezawa.hiroyu@jp.fujitsu.com> <4F44F54A.8010902@parallels.com>
In-Reply-To: <4F44F54A.8010902@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>

On 02/22/2012 12:01 PM, Glauber Costa wrote:
> On 02/22/2012 04:46 AM, KAMEZAWA Hiroyuki wrote:
>> On Tue, 21 Feb 2012 15:34:33 +0400
>> Glauber Costa<glommer@parallels.com> wrote:
>>
>>> Move some hardcoded definitions to an enum type.
>>>
>>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>>> CC: Kirill A. Shutemov<kirill@shutemov.name>
>>> CC: Greg Thelen<gthelen@google.com>
>>> CC: Johannes Weiner<jweiner@redhat.com>
>>> CC: Michal Hocko<mhocko@suse.cz>
>>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>>> CC: Paul Turner<pjt@google.com>
>>> CC: Frederic Weisbecker<fweisbec@gmail.com>
>>
>> seems ok to me.
>>
>> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> BTW, this series is likely to go through many rounds of discussion.
> This patch can be probably picked separately, if you want to.
>
>> a nitpick..
>>
>>> ---
>>> mm/memcontrol.c | 10 +++++++---
>>> 1 files changed, 7 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 6728a7a..b15a693 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -351,9 +351,13 @@ enum charge_type {
>>> };
>>>
>>> /* for encoding cft->private value on file */
>>> -#define _MEM (0)
>>> -#define _MEMSWAP (1)
>>> -#define _OOM_TYPE (2)
>>> +
>>> +enum mem_type {
>>> + _MEM = 0,
>>
>> =0 is required ?
> I believe not, but I always liked to use it to be 100 % explicit.
> Personal taste... Can change it, if this is a big deal.

Kame, would you like me to send this cleanup without the = 0 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
