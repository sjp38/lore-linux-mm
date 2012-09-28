Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 338CB6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 21:45:26 -0400 (EDT)
Received: by obcva7 with SMTP id va7so3077578obc.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:45:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5064FDCA.1020504@jp.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
 <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
 <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
 <5064FDCA.1020504@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 27 Sep 2012 21:37:50 -0400
Message-ID: <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

>> Moreover, your explanation is still insufficient. Even if
>> node_device_release() is empty function, we can get rid of the
>> warning.
>
>
> I don't understand it. How can we get rid of the warning?

See cpu_device_release() for example.



>> Why do we need this node_device_release() implementation?
>
> I think that this is a manner of releasing object related kobject.

No.  Usually we never call memset() from release callback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
