Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3FF216B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 00:36:12 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2350171bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 21:36:10 -0700 (PDT)
Message-ID: <4F7E72B3.8000604@openvz.org>
Date: Fri, 06 Apr 2012 08:36:03 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120331201324.GA17565@redhat.com> <20120402230423.GB32299@count0.beaverton.ibm.com> <4F7A863C.5020407@openvz.org> <20120403181631.GD32299@count0.beaverton.ibm.com> <20120403193204.GE3370@moon> <20120405202904.GB7761@count0.beaverton.ibm.com> <4F7E08EB.5070600@openvz.org> <20120405214447.GC7761@count0.beaverton.ibm.com> <CA+55aFzH=nTAxxqMpQKJAVFOEngwkArmufqe_Mq5hyLR_9Vfqw@mail.gmail.com>
In-Reply-To: <CA+55aFzH=nTAxxqMpQKJAVFOEngwkArmufqe_Mq5hyLR_9Vfqw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Helsley <matthltc@us.ibm.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Al Viro <viro@zeniv.linux.org.uk>

Linus Torvalds wrote:
> On Thu, Apr 5, 2012 at 2:44 PM, Matt Helsley<matthltc@us.ibm.com>  wrote:
>>
>> I don't think the definition of an ABI is whether there's documentation
>> for it. It's whether the interface is used or not. At least that's the
>> impression I've gotten from reading Linus' rants over the years.
>
> Yes.
>
> That said, I *do* have some very dim memory of us having had real
> issues with the /proc/<pid>/exe thing and having regressions due to
> holding refcounts to executables that were a.out binaries and not
> demand-loaded. And people wanting to unmount filesystems despite the
> binaries being live.
>
> That said, I suspect that whatever issues we used to have with that
> are pretty long gone. I don't think people use non-mmap'ed binaries
> any more. So I think we can try it and see. And revert if somebody
> actually notices and has problems.

Instead of tracking count of vma with VM_EXECUTABLE bit we can track
count of vma with vma->vm_file == mm->exe_file, this will be nearly
the same behaviour. This was in early version of my patch, but I prefer
to go deeper. So, we can revert it without introducing VM_EXECUTABLE again.

>
>                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
