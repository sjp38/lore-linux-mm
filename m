Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 933806B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:01:56 -0500 (EST)
Message-ID: <4F354D51.7020408@redhat.com>
Date: Fri, 10 Feb 2012 12:01:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
References: <bug-42578-27@https.bugzilla.kernel.org/> <201201180922.q0I9MCYl032623@bugzilla.kernel.org> <20120119122448.1cce6e76.akpm@linux-foundation.org> <20120210163748.GR5796@csn.ul.ie>
In-Reply-To: <20120210163748.GR5796@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Stuart Foster <smf.linux@ntlworld.com>, Johannes Weiner <hannes@cmpxchg.org>

On 02/10/2012 11:37 AM, Mel Gorman wrote:
> On Thu, Jan 19, 2012 at 12:24:48PM -0800, Andrew Morton wrote:

>> I think it is was always wrong that we only strip buffer_heads when
>> moving pages to the inactive list.  What happens if those 600MB of
>> buffer_heads are all attached to inactive pages?
>>
>
> I wondered the same thing myself. With some use-once logic, there is
> no guarantee that they even get promoted to the active list in the
> first place. It's "always" been like this but we've changed how pages gets
> promoted quite a bit and this use case could have been easily missed.

It may be possible to also strip the buffer heads from
pages when they are moved to the active list, in
activate_page().

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
