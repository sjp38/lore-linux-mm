Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C4C526B0099
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 14:12:34 -0400 (EDT)
Received: by obcva7 with SMTP id va7so6652831obc.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2012 11:12:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50693E30.3010006@jp.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
 <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
 <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
 <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
 <5065740A.2000502@jp.fujitsu.com> <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com>
 <50693E30.3010006@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 1 Oct 2012 14:12:13 -0400
Message-ID: <CAHGf_=qZVe_KfThZa5yEm+4w3MMREs1xqya5HmKWsWjyTcjkzA@mail.gmail.com>
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

On Mon, Oct 1, 2012 at 2:54 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> Hi Kosaki-san,
>
>
> 2012/09/29 7:19, KOSAKI Motohiro wrote:
>>>>>
>>>>> I don't understand it. How can we get rid of the warning?
>>>>
>>>>
>>>> See cpu_device_release() for example.
>>>
>>>
>>> If we implement a function like cpu_device_release(), the warning
>>> disappears. But the comment says in the function "Never copy this
>>> way...".
>>> So I think it is illegal way.
>>
>>
>> What does "illegal" mean?
>
>
> The "illegal" means the code should not be mimicked.
>
>
>> You still haven't explain any benefit of your code. If there is zero
>> benefit, just kill it.
>> I believe everybody think so.
>>
>> Again, Which benefit do you have?
>
>
> The patch has a benefit to delets a warning message.
>
>
>>
>>>>>> Why do we need this node_device_release() implementation?
>>>>>
>>>>>
>>>>> I think that this is a manner of releasing object related kobject.
>>>>
>>>>
>>>> No.  Usually we never call memset() from release callback.
>>>
>>>
>>> What we want to release is a part of array, not a pointer.
>>> Therefore, there is only this way instead of kfree().
>>
>>
>> Why? Before your patch, we don't have memset() and did work it.
>
>
> If we does not apply the patch, a warning message is shown.
> So I think it did not work well.
>
>
>> I can't understand what mean "only way".
>
>
> For deleting a warning message, I created a node_device_release().
> In the manner of releasing kobject, the function frees a object related
> to the kobject. So most functions calls kfree() for releasing it.
> In node_device_release(), we need to free a node struct. If the node
> struct is pointer, I can free it by kfree. But the node struct is a part
> of node_devices[] array. I cannot free it. So I filled the node struct
> with 0.
>
> But you think it is not good. Do you have a good solution?

Do nothing. just add empty release function and kill a warning.
Obviously do nothing can't make any performance drop nor any
side effect.

meaningless memset() is just silly from point of cache pollution view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
