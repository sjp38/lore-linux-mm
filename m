Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 7033A6B005C
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 01:12:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 60DE13EE0BD
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 14:12:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4992345DEAD
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 14:12:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 346ED45DE7E
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 14:12:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 277111DB803E
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 14:12:20 +0900 (JST)
Received: from g01jpexchkw10.g01.fujitsu.local (g01jpexchkw10.g01.fujitsu.local [10.0.194.49])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D88BF1DB8038
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 14:12:19 +0900 (JST)
Message-ID: <4FFFAE17.7070400@jp.fujitsu.com>
Date: Fri, 13 Jul 2012 14:11:51 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/13] memory-hotplug : unify argument of firmware_map_add_early/hotplug
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB17F.2090209@jp.fujitsu.com> <4FFD9C08.2070502@linux.vnet.ibm.com> <4FFE5816.6070102@jp.fujitsu.com> <4FFED3CE.7030108@linux.vnet.ibm.com>
In-Reply-To: <4FFED3CE.7030108@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Hi Dave,

2012/07/12 22:40, Dave Hansen wrote:
> On 07/11/2012 09:52 PM, Yasuaki Ishimatsu wrote:
>> Does the following patch include your comment? If O.K., I will separate
>> the patch from the series and send it for bug fix.
> 
> Looks sane to me.  It does now mean that the calling conventions for
> some of the other firmware_map*() functions are different, but I think
> that's OK since they're only used internally to memmap.c.

Can I add "Reviewed-by: Dave Hansen" to the patch?

Thanks,
Yasuaki Ishimatsu

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
