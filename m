Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 4639C6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 21:31:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9BD9E3EE0BD
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:31:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80DEC45DEBE
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:31:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66C3E45DEB6
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:31:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 579E21DB8038
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:31:15 +0900 (JST)
Received: from g01jpexchkw09.g01.fujitsu.local (g01jpexchkw09.g01.fujitsu.local [10.0.194.48])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B523E1DB8041
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:31:14 +0900 (JST)
Message-ID: <5064FDCA.1020504@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 10:30:50 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com> <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
In-Reply-To: <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/09/28 10:13, KOSAKI Motohiro wrote:
> On Thu, Sep 27, 2012 at 8:07 PM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> Hi Kosaki-san,
>>
>>
>> 2012/09/28 5:13, KOSAKI Motohiro wrote:
>>>
>>> On Thu, Sep 27, 2012 at 1:45 AM,  <wency@cn.fujitsu.com> wrote:
>>>>
>>>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>
>>>> When calling unregister_node(), the function shows following message at
>>>> device_release().
>>>
>>>
>>> This description doesn't have the "following message".
>>>
>>>
>>
>>>> Device 'node2' does not have a release() function, it is broken and must
>>>> be
>>>> fixed.
>>
>>
>> This is the messages. The message is shown by kobject_cleanup(), when
>> calling
>> unregister_node().
>
> If so, you should quote the message. and don't mix it with your
> subject. Moreover
> your patch title is too silly. "add node_device_release() function" is
> a way. you should
> describe the effect of the patch. e.g. suppress "Device 'nodeXX' does
> not have a release() function" warning.

What you say is correct. We should update subject and changelog.

>
> Moreover, your explanation is still insufficient. Even if
> node_device_release() is empty function, we can get rid of the
> warning.

I don't understand it. How can we get rid of the warning?

> Why do we need this node_device_release() implementation?

I think that this is a manner of releasing object related kobject.

Thanks,
Yasuaki Ishimatsu




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
