Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DE8A76B007E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 17:55:51 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so155313wgb.2
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 14:55:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120405214447.GC7761@count0.beaverton.ibm.com>
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com> <20120402230423.GB32299@count0.beaverton.ibm.com>
 <4F7A863C.5020407@openvz.org> <20120403181631.GD32299@count0.beaverton.ibm.com>
 <20120403193204.GE3370@moon> <20120405202904.GB7761@count0.beaverton.ibm.com>
 <4F7E08EB.5070600@openvz.org> <20120405214447.GC7761@count0.beaverton.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Apr 2012 14:55:29 -0700
Message-ID: <CA+55aFzH=nTAxxqMpQKJAVFOEngwkArmufqe_Mq5hyLR_9Vfqw@mail.gmail.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Apr 5, 2012 at 2:44 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
>
> I don't think the definition of an ABI is whether there's documentation
> for it. It's whether the interface is used or not. At least that's the
> impression I've gotten from reading Linus' rants over the years.

Yes.

That said, I *do* have some very dim memory of us having had real
issues with the /proc/<pid>/exe thing and having regressions due to
holding refcounts to executables that were a.out binaries and not
demand-loaded. And people wanting to unmount filesystems despite the
binaries being live.

That said, I suspect that whatever issues we used to have with that
are pretty long gone. I don't think people use non-mmap'ed binaries
any more. So I think we can try it and see. And revert if somebody
actually notices and has problems.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
