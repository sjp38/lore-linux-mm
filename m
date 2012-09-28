Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2B8516B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 05:55:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DD4E63EE0BD
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:55:56 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C47D545DE60
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:55:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB5C045DE59
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:55:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D7BC1DB8055
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:55:56 +0900 (JST)
Received: from g01jpexchkw31.g01.fujitsu.local (g01jpexchkw31.g01.fujitsu.local [10.0.193.114])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A0F01DB804C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:55:56 +0900 (JST)
Message-ID: <5065740A.2000502@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 18:55:22 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com> <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com> <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
In-Reply-To: <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/09/28 10:37, KOSAKI Motohiro wrote:
>>> Moreover, your explanation is still insufficient. Even if
>>> node_device_release() is empty function, we can get rid of the
>>> warning.
>>
>>
>> I don't understand it. How can we get rid of the warning?
>
> See cpu_device_release() for example.

If we implement a function like cpu_device_release(), the warning
disappears. But the comment says in the function "Never copy this way...".
So I think it is illegal way.

>
>
>
>>> Why do we need this node_device_release() implementation?
>>
>> I think that this is a manner of releasing object related kobject.
>
> No.  Usually we never call memset() from release callback.
>

What we want to release is a part of array, not a pointer.
Therefore, there is only this way instead of kfree().

Thanks,
Yasuaki Ishimatsu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
