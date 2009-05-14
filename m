Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDDA66B015D
	for <linux-mm@kvack.org>; Wed, 13 May 2009 21:39:58 -0400 (EDT)
Date: Thu, 14 May 2009 11:40:32 +1000
From: Tony Breeds <tony@bakeyournoodle.com>
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
Message-ID: <20090514014032.GX16602@bilbo.ozlabs.org>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com> <1240191366-10029-2-git-send-email-ieidus@redhat.com> <1240191366-10029-3-git-send-email-ieidus@redhat.com> <1240191366-10029-4-git-send-email-ieidus@redhat.com> <1240191366-10029-5-git-send-email-ieidus@redhat.com> <1240191366-10029-6-git-send-email-ieidus@redhat.com> <20090513161739.d801ab67.akpm@linux-foundation.org> <4A0B6289.2000502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4A0B6289.2000502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 03:15:05AM +0300, Izik Eidus wrote:

> Hi
>
> There is some way (script) that i can run that will allow compile this  
> code for every possible arch?

Segher Boessenkool has a tool for builing cross toolchains and the kernel
at git://git.infradead.org/users/segher/buildall.git  You can save
yourself some time (and pain) and use the built toolchains at:
	http://bakeyournoodle.com/cross

If there is any interest I can get these toolchains hosted on a faster machine
(say kernel.org)

Yours Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
