Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2B0CA6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 20:08:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 543703EE0BC
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:08:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3852145DE58
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:08:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DB7E45DE55
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:08:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F11E1DB8052
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:08:19 +0900 (JST)
Received: from G01JPEXCHKW23.g01.fujitsu.local (G01JPEXCHKW23.g01.fujitsu.local [10.0.193.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC69D1DB8045
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:08:18 +0900 (JST)
Message-ID: <5064EA5A.3080905@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 09:07:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
In-Reply-To: <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/09/28 5:13, KOSAKI Motohiro wrote:
> On Thu, Sep 27, 2012 at 1:45 AM,  <wency@cn.fujitsu.com> wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> When calling unregister_node(), the function shows following message at
>> device_release().
>
> This description doesn't have the "following message".
>
>

>> Device 'node2' does not have a release() function, it is broken and must be
>> fixed.

This is the messages. The message is shown by kobject_cleanup(), when calling
unregister_node().

Thanks,
Yasuaki Ishimatsu

>>
>> So the patch implements node_device_release()
>>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
