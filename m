Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4C98C6B00F6
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 18:05:26 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2955206bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:05:24 -0700 (PDT)
Message-ID: <4F6BA221.8020602@openvz.org>
Date: Fri, 23 Mar 2012 02:05:21 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg> <20120321100602.GA5522@barrios>	<4F69D496.2040509@openvz.org> <20120322142647.42395398.akpm@linux-foundation.org> <20120322212810.GE6589@ZenIV.linux.org.uk> <20120322144122.59d12051.akpm@linux-foundation.org>
In-Reply-To: <20120322144122.59d12051.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

Andrew Morton wrote:
> On Thu, 22 Mar 2012 21:28:11 +0000
> Al Viro<viro@ZenIV.linux.org.uk>  wrote:
>
>> On Thu, Mar 22, 2012 at 02:26:47PM -0700, Andrew Morton wrote:
>>> It would be nice to find some way of triggering compiler warnings or
>>> sparse warnings if someone mixes a 32-bit type with a vm_flags_t.  Any
>>> thoughts on this?
>>>
>>> (Maybe that's what __nocast does, but Documentation/sparse.txt doesn't
>>> describe it)
>>
>> Use __bitwise for that - check how gfp_t is handled.
>
> So what does __nocast do?

Actually it forbid any non-forced casts, but its implementation in sparse seems buggy:
__nocast generates some strange false positives. For example it sometimes forgot about
type attributes in function arguments, I saw this for vm_flags argument in ksm_madvise().
I can reproduce this bug, if somebody interested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
