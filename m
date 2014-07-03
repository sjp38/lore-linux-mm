Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 527976B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:54:00 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so673618pad.13
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:54:00 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id qm4si1081741pdb.126.2014.07.03.11.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:53:58 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 4 Jul 2014 04:53:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6E7433578048
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 04:53:51 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63IrYbV1704424
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 04:53:35 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63IropB028409
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 04:53:50 +1000
Message-ID: <53B5A5FE.2080500@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2014 00:20:38 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com> <53B59CB5.9060004@linux.vnet.ibm.com> <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com> <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com> <53B5A343.4090402@linux.vnet.ibm.com>
In-Reply-To: <53B5A343.4090402@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/04/2014 12:08 AM, Raghavendra K T wrote:
> On 07/03/2014 11:59 PM, Linus Torvalds wrote:
>> On Thu, Jul 3, 2014 at 11:22 AM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
[...]
t.
>>
>> I do *not* think we should bow down to insane man-pages that have
>> always been wrong, though, and I don't think we should increase it to
>> "let's just read-ahead a whole ISO image" kind of sizes..
>
> Okay, how about something like 256MB? I would be happy to send a patch
> for that change.

Sorry I was too fast. I think some thing like 16MB? I 'll send patch
with that (unless you different size in mind).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
