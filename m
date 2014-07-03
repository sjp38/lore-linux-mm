Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D467D6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:38:41 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so640800pdb.16
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:38:41 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id sx5si33519149pab.126.2014.07.03.11.38.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:38:40 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 4 Jul 2014 00:08:36 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 5FCA7E0053
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 00:09:55 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63Idv1G62783626
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 00:09:57 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63IcXlE022374
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 00:08:33 +0530
Message-ID: <53B5A26B.7040606@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2014 00:05:23 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com> <53B59CB5.9060004@linux.vnet.ibm.com> <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
In-Reply-To: <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/03/2014 11:52 PM, Linus Torvalds wrote:
> On Thu, Jul 3, 2014 at 11:11 AM, Raghavendra K T
> <raghavendra.kt@linux.vnet.ibm.com> wrote:
>>>
>>> If this comes from some man-page,
>>
>> Yes it is.
>
> Ok, googling actually finds a fairly recent patch to fix it
>
>     http://www.spinics.net/lists/linux-mm/msg70517.html
>
> and several much older "that's not true" comments.

Thanks. I had missed that.

>
> That said, the bugzilla entry you mentioned does mention "can't boot
> 3.14 now". I'm not sure what the meaning of that sentence is, though.
> Does it mean "can't boot 3.14 to test it because the machine is busy",
> or is it a typo and really meant 3.15, and that some bootup script
> *depended* on readahead()? I don't know. It seems strange.

I think your guess is right, it meant to say "I can't boot it anymore
since I already upgraded to 3.15", because eventually bootup script (if
it is) should have to read IIUC.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
