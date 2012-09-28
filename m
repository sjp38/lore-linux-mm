Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 4BA4F6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:19:59 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4620297vbk.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:19:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5065740A.2000502@jp.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
 <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
 <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
 <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
 <5065740A.2000502@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 18:19:36 -0400
Message-ID: <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com>
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

>>> I don't understand it. How can we get rid of the warning?
>>
>> See cpu_device_release() for example.
>
> If we implement a function like cpu_device_release(), the warning
> disappears. But the comment says in the function "Never copy this way...".
> So I think it is illegal way.

What does "illegal" mean?
You still haven't explain any benefit of your code. If there is zero
benefit, just kill it.
I believe everybody think so.

Again, Which benefit do you have?


>>>> Why do we need this node_device_release() implementation?
>>>
>>> I think that this is a manner of releasing object related kobject.
>>
>> No.  Usually we never call memset() from release callback.
>
> What we want to release is a part of array, not a pointer.
> Therefore, there is only this way instead of kfree().

Why? Before your patch, we don't have memset() and did work it.
I can't understand what mean "only way".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
