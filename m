Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2D36B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:16:51 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f73so4119047yha.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:16:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si2666701qac.26.2015.02.12.02.16.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 02:16:50 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 1/3] driver core: export lock_device_hotplug/unlock_device_hotplug
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
	<1423669462-30918-2-git-send-email-vkuznets@redhat.com>
	<20150211123947.3318933f2aca54e11324b088@linux-foundation.org>
	<2420637.jF050I0e1M@vostro.rjw.lan>
Date: Thu, 12 Feb 2015 11:16:31 +0100
In-Reply-To: <2420637.jF050I0e1M@vostro.rjw.lan> (Rafael J. Wysocki's message
	of "Thu, 12 Feb 2015 05:04:28 +0100")
Message-ID: <87wq3nzb7k.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org

"Rafael J. Wysocki" <rjw@rjwysocki.net> writes:

> On Wednesday, February 11, 2015 12:39:47 PM Andrew Morton wrote:
>> On Wed, 11 Feb 2015 16:44:20 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>> 
>> > add_memory() is supposed to be run with device_hotplug_lock grabbed, otherwise
>> > it can race with e.g. device_online(). Allow external modules (hv_balloon for
>> > now) to lock device hotplug.
>> > 
>> > ...
>> >
>> > --- a/drivers/base/core.c
>> > +++ b/drivers/base/core.c
>> > @@ -55,11 +55,13 @@ void lock_device_hotplug(void)
>> >  {
>> >  	mutex_lock(&device_hotplug_lock);
>> >  }
>> > +EXPORT_SYMBOL_GPL(lock_device_hotplug);
>> >  
>> >  void unlock_device_hotplug(void)
>> >  {
>> >  	mutex_unlock(&device_hotplug_lock);
>> >  }
>> > +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
>> >  
>> >  int lock_device_hotplug_sysfs(void)
>> >  {
>> 
>> It's kinda crazy that lock_device_hotplug_sysfs() didn't get any
>> documentation.  I suggest adding this while you're in there:
>> 
>> 
>> --- a/drivers/base/core.c~a
>> +++ a/drivers/base/core.c
>> @@ -61,6 +61,9 @@ void unlock_device_hotplug(void)
>>  	mutex_unlock(&device_hotplug_lock);
>>  }
>>  
>> +/*
>> + * "git show 5e33bc4165f3ed" for details
>> + */
>>  int lock_device_hotplug_sysfs(void)
>>  {
>>  	if (mutex_trylock(&device_hotplug_lock))
>> 
>> which is a bit lazy but whatev.
>> 
>> I'll assume that Greg (or Rafael?) will be processing this patchset.
>
> Well, I would do that if I saw it (my address in the CC has been deprecated
> for several months now).
>
> Vitaly, can you please resend with a CC to a valid address of mine,
> please?

Yes, sure, for some reason you were not on the get_maintainer.pl output.

>
> Rafael

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
