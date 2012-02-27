Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2E8AF6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 13:32:40 -0500 (EST)
Message-ID: <4F4BCC4A.1090402@fb.com>
Date: Mon, 27 Feb 2012 10:32:42 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com> <4F468888.9090702@fb.com> <20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com> <CAKTCnzk7TgDeYRZK0rCugopq0tO7BtM8jM9U0RJUTqNtz42ZKw@mail.gmail.com> <4F47E0D0.9030409@fb.com> <CAKTCnznyZGLiZPNS151GzsUMApN_SYu3n6xX9E0ceMpq9JNq7w@mail.gmail.com>
In-Reply-To: <CAKTCnznyZGLiZPNS151GzsUMApN_SYu3n6xX9E0ceMpq9JNq7w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 2/24/12 8:13 PM, Balbir Singh wrote:
>> A uid based approach such as the one implemented by Davide Libenzi
>>
>> http://thread.gmane.org/gmane.linux.kernel/548928
>> http://thread.gmane.org/gmane.linux.kernel/548926
>>
>> would probably apply the optimization to more use cases - but conceptually a
>> bit more complex. If we go with this more relaxed approach, we'll have to
>> design a race-free cgroup_uid_count() based mechanism.
>
> Are you suggesting all processes with the same UID should have access
> to each others memory contents?

No - that's a stronger statement than the one I made in my last message. 
I'll however observe that something like this is already possible via 
PTRACE_PEEKDATA.

Like I said: a cgroup with a single mm_struct is conceptually cleanest 
and covers some of our heavy use cases. A cgroup with a single uid would 
cover more of our use cases. It'd be good to know if you and other 
maintainers are willing to accept the former, but not the latter.

I'll note that the malloc implementation which uses these interfaces can 
still decide to zero the memory depending on which variant of *alloc is 
called. But then, we'd have more fine grained control and more 
flexibility in terms of temporal usage hints.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
