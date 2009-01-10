Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D87D46B009A
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 19:37:34 -0500 (EST)
Date: Fri, 9 Jan 2009 16:37:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
Message-Id: <20090109163725.11294fb1.akpm@linux-foundation.org>
In-Reply-To: <604427e00901091627n7c909abt6aa1f01c181ad65d@mail.gmail.com>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
	<604427e00901081840pa6dcc41u9a7a5c69302c7b60@mail.gmail.com>
	<604427e00901091627n7c909abt6aa1f01c181ad65d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mikew@google.com, rohitseth@google.com, linux-api@vger.kernel.org, oleg@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 16:27:07 -0800
Ying Han <yinghan@google.com> wrote:

> friendly ping...

We'll get there.  We're in the merge window now, so I tend to defer
non-serious bugfixes until things are a bit quieter.

> On Thu, Jan 8, 2009 at 6:40 PM, Ying Han <yinghan@google.com> wrote:
> > On Mon, Jan 5, 2009 at 3:39 PM, Ying Han <yinghan@google.com> wrote:
> >> From: Ying Han <yinghan@google.com>
> >>
> >> Fix 32bit binary get 64bit stack vma offset.
> >>
> >> 32bit binary running on 64bit system, the /proc/pid/maps shows for the
> >> vma represents stack get a 64bit adress:
> >> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]

That changelog hurts my brain.

> >> Signed-off-by:  Ying Han <yinghan@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
