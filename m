Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 87BCA6B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 06:13:53 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2668394bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 03:13:51 -0700 (PDT)
Message-ID: <4F797BDD.2020905@openvz.org>
Date: Mon, 02 Apr 2012 14:13:49 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120331201324.GA17565@redhat.com> <20120331203912.GB687@moon> <4F79755B.3030703@openvz.org> <20120402095444.GE7607@moon>
In-Reply-To: <20120402095444.GE7607@moon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Matt Helsley <matthltc@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

Cyrill Gorcunov wrote:
> On Mon, Apr 02, 2012 at 01:46:03PM +0400, Konstantin Khlebnikov wrote:
>> Cyrill Gorcunov wrote:
>>> On Sat, Mar 31, 2012 at 10:13:24PM +0200, Oleg Nesterov wrote:
>>>>
>>>> Add Cyrill. This conflicts with
>>>> c-r-prctl-add-ability-to-set-new-mm_struct-exe_file.patch in -mm.
>>>
>>> Thanks for CC'ing, Oleg. I think if thise series go in it won't
>>> be a problem to update my patch accordingly.
>>
>> In this patch I leave mm->exe_file lockless.
>> After exec/fork we can change it only for current task and only if mm->mm_users == 1.
>>
>> something like this:
>>
>> task_lock(current);
>> if (atomic_read(&current->mm->mm_users) == 1)
>> 	set_mm_exe_file(current->mm, new_file);
>> else
>> 	ret = -EBUSY;
>> task_unlock(current);
>>
>> task_lock() protect this code against get_task_mm()
>
> I see. Konstantin, the question is what is more convenient way to update the
> patch in linux-next. The c-r-prctl-add-ability-to-set-new-mm_struct-exe_file.patch
> is in -mm already, so I either should wait until Andrew pick your series up and
> send updating patch on top, or I could fetch your series, update my patch and
> send it here as reply. Hmm?

Let's wait for Andrew's response. And maybe somebody disagree with my changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
