Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id EAB856B003A
	for <linux-mm@kvack.org>; Thu,  9 May 2013 12:25:01 -0400 (EDT)
Date: Thu, 9 May 2013 16:25:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 00/22] Per-cpu page allocator replacement prototype
In-Reply-To: <518BC3BD.30005@sr71.net>
Message-ID: <0000013e8a1c2415-a5cdffec-1de7-4814-ae75-0965a645edb2-000000@email.amazonses.com>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de> <518BC3BD.30005@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 May 2013, Dave Hansen wrote:

> BTW, I really like the 'magazine' name.  It's not frequently used in
> this kind of context and it conjures up a nice mental image whether it
> be of stacks of periodicals or firearm ammunition clips.

The term "magazine" was prominently used in the Bonwick article that was
the base of the creation of the SLAB allocator.

http://static.usenix.org/event/usenix01/full_papers/bonwick/bonwick.pdf

http://static.usenix.org/publications/library/proceedings/bos94/full_papers/bonwick.a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
