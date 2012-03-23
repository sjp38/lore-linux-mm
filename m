Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A8A886B0111
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 13:29:04 -0400 (EDT)
Message-ID: <4F6CA298.4000301@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 12:19:36 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg> <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org> <20120322142647.42395398.akpm@linux-foundation.org> <20120322212810.GE6589@ZenIV.linux.org.uk>
In-Reply-To: <20120322212810.GE6589@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: akpm@linux-foundation.org, khlebnikov@openvz.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hughd@google.com, kosaki.motohiro@jp.fujitsu.com, benh@kernel.crashing.org, linux@arm.linux.org.uk

On 3/22/2012 5:28 PM, Al Viro wrote:
> On Thu, Mar 22, 2012 at 02:26:47PM -0700, Andrew Morton wrote:
>> It would be nice to find some way of triggering compiler warnings or
>> sparse warnings if someone mixes a 32-bit type with a vm_flags_t.  Any
>> thoughts on this?
>>
>> (Maybe that's what __nocast does, but Documentation/sparse.txt doesn't
>> describe it)
> 
> Use __bitwise for that - check how gfp_t is handled.

Hmm..

If now we activate __bitwise, really plenty driver start create lots warnings.
Does it make sense?

In fact, x86-32 keep 32bit vma_t forever. thus all x86 specific driver don't
need any change. Moreover many ancient drivers has no maintainer and I can't
expect such driver will be fixed even though a warning occur.

So, I think __nocast weakness is better than strict __bitwise annotation for
this situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
