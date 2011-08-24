Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 30F6C6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 10:24:46 -0400 (EDT)
Date: Wed, 24 Aug 2011 09:24:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 08/13] list: add a new LRU list type
In-Reply-To: <4E5379DA.8060109@openvz.org>
Message-ID: <alpine.DEB.2.00.1108240923420.24118@router.home>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com> <1314089786-20535-9-git-send-email-david@fromorbit.com> <20110823092056.GE21492@infradead.org> <20110823093205.GZ3162@dastard> <4E5379DA.8060109@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 23 Aug 2011, Konstantin Khlebnikov wrote:

> maybe is better to rename it to enum page_lru_list

Better rename both and clearly indicate what type of lru list it is. An
LRU list is such a generic concept that it shows up in an excessive amount
of contexts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
