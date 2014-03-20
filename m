Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D9D2D6B01AE
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 06:36:54 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so431358wgh.28
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 03:36:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si1275378wiv.58.2014.03.20.03.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 03:36:52 -0700 (PDT)
Message-ID: <532AC4C2.4050406@suse.cz>
Date: Thu, 20 Mar 2014 11:36:50 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com> <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org> <530A4CBE.5090305@oracle.com> <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL> <5314A9E9.6090802@suse.cz> <20140311184353.GA10764@redhat.com> <532AB274.3030800@oracle.com>
In-Reply-To: <532AB274.3030800@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>, Dave Jones <davej@redhat.com>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>

On 03/20/2014 10:18 AM, Bob Liu wrote:
>
> On 03/12/2014 02:43 AM, Dave Jones wrote:
>> On Mon, Mar 03, 2014 at 05:12:25PM +0100, Vlastimil Babka wrote:
>>
>>   > >> On 01/31/2014 03:33 PM, Andrew Morton wrote:
>>   > >>> On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
>>   > >>>
>>   > >>>>> This BUG_ON() was triggered when called from try_to_unmap_cluster()
>>   > >>>>> which didn't lock the page.
>>   > >>>>> And it's safe to mlock_vma_page() without PageLocked, so this patch
>>   > >>>>> fix this issue by removing that BUG_ON() simply.
>>   > >>>>>
>>   > >>> This patch doesn't appear to be going anywhere, so I will drop it.
>>   > >>> Please let's check to see whether the bug still exists and if so,
>>   > >>> start another round of bugfixing.
>>   > >>
>>   > >> This bug still happens on the latest -next kernel.
>>   > >
>>   > > Yeah, I recognized it. I'm preparing new patch. Thanks.
>>   >
>>   > What will be your approach? After we had the discussion some month ago
>>   > about m(un)lock vs migration I've concluded that there is no race that
>>   > page lock helps, and removing the BUG_ON() would be indeed correct. Just
>>   > needs to be correctly explained and documentation updated as well.
>>
>> This is not just a -next problem btw, I just hit this in 3.14-rc6
>>
>
> It seems the fix patch from Vlastimil was missed, I've resend it to Andrew.

Well, there was a followup discussion with Motohiro Kosaki that 
convinced me to go with the "remove BUG_ON()" again, but I didn't get to 
it yet to thoroughly check that it's indeed safe.
However, my patch could work around the issue until we decide that page 
lock is indeed not needed. Which should still happen one way or another, 
because as Motohiro also pointed out, current munlock code already does 
PageMlocked flag manipulation without page lock.
So thanks for resend.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
