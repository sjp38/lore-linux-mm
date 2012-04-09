Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 08E246B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 19:40:48 -0400 (EDT)
Message-ID: <4F83737B.7040308@redhat.com>
Date: Mon, 09 Apr 2012 19:40:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] Removal of lumpy reclaim
References: <1332950783-31662-1-git-send-email-mgorman@suse.de> <20120406123439.d2ba8920.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061316580.3057@eggly.anvils> <4F8325FB.80409@redhat.com> <alpine.LSU.2.00.1204091205130.1536@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204091205130.1536@eggly.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On 04/09/2012 03:18 PM, Hugh Dickins wrote:
> On Mon, 9 Apr 2012, Rik van Riel wrote:

>> I could see NOMMU being unable to use compaction, but
>
> Yes, COMPACTION depends on MMU.
>
>> chances are lumpy reclaim would be sufficient for that
>> configuration, anyway...
>
> That's an argument for your patch in 3.4-rc, which uses lumpy only
> when !COMPACTION_BUILD.  But here we're worrying about Mel's patch,
> which removes the lumpy code completely.

Sorry, that was a typo in my mail.

I wanted to say that I expect lumpy reclaim to NOT be
sufficient for NOMMU anyway, because it cannot reclaim
lumps of memory large enough to fit a new process.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
