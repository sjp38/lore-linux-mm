Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id B49246B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:42:34 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id at1so687457iec.35
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:42:34 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id e9si8354443ict.95.2014.07.03.11.42.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:42:33 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 4 Jul 2014 00:12:11 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 15E79E0045
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 00:13:30 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63IgPYs61407302
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 00:12:25 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63Ig8te031046
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 00:12:08 +0530
Message-ID: <53B5A343.4090402@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2014 00:08:59 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com> <53B59CB5.9060004@linux.vnet.ibm.com> <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com> <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
In-Reply-To: <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/03/2014 11:59 PM, Linus Torvalds wrote:
> On Thu, Jul 3, 2014 at 11:22 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> So the bugzilla entry worries me a bit - we definitely do not want to
>> regress in case somebody really relied on timing - but without more
>> specific information I still think the real bug is just in the
>> man-page.
>
> Side note: the 2MB limit may be too small. 2M is peanuts on modern
> machines, even for fairly slow IO, and there are lots of files (like
> glibc etc) that people might want to read-ahead during boot. We
> already do bigger read-ahead if people just do "read()" system calls.
> So I could certainly imagine that we should increase it.
>
> I do *not* think we should bow down to insane man-pages that have
> always been wrong, though, and I don't think we should increase it to
> "let's just read-ahead a whole ISO image" kind of sizes..

Okay, how about something like 256MB? I would be happy to send a patch
for that change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
