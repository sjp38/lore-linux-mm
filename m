Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7156A6B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 11:12:31 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id e51so3126251eek.12
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 08:12:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oo3si541068bkb.99.2014.03.03.08.12.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 08:12:29 -0800 (PST)
Message-ID: <5314A9E9.6090802@suse.cz>
Date: Mon, 03 Mar 2014 17:12:25 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com> <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org> <530A4CBE.5090305@oracle.com> <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL>
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Bob Liu <bob.liu@oracle.com>

On 02/24/2014 06:57 PM, Motohiro Kosaki wrote:
>
>
>> -----Original Message-----
>> From: Sasha Levin [mailto:sasha.levin@oracle.com]
>> Sent: Sunday, February 23, 2014 2:32 PM
>> To: Andrew Morton; Bob Liu
>> Cc: linux-mm@kvack.org; walken@google.com; Motohiro Kosaki JP;
>> riel@redhat.com; vbabka@suse.cz; stable@kernel.org;
>> gregkh@linuxfoundation.org; Bob Liu
>> Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
>>
>> On 01/31/2014 03:33 PM, Andrew Morton wrote:
>>> On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
>>>
>>>>> This BUG_ON() was triggered when called from try_to_unmap_cluster()
>>>>> which didn't lock the page.
>>>>> And it's safe to mlock_vma_page() without PageLocked, so this patch
>>>>> fix this issue by removing that BUG_ON() simply.
>>>>>
>>> This patch doesn't appear to be going anywhere, so I will drop it.
>>> Please let's check to see whether the bug still exists and if so,
>>> start another round of bugfixing.
>>
>> This bug still happens on the latest -next kernel.
>
> Yeah, I recognized it. I'm preparing new patch. Thanks.

What will be your approach? After we had the discussion some month ago 
about m(un)lock vs migration I've concluded that there is no race that 
page lock helps, and removing the BUG_ON() would be indeed correct. Just 
needs to be correctly explained and documentation updated as well.

Vlastimil

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
