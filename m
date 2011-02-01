Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1973E8D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 05:12:11 -0500 (EST)
Date: Tue, 1 Feb 2011 11:12:07 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 6/6] have smaps show transparent huge pages
Message-ID: <20110201101207.GL19534@cmpxchg.org>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201003405.FC58B813@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110201003405.FC58B813@kernel>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 04:34:05PM -0800, Dave Hansen wrote:
> 
> Now that the mere act of _looking_ at /proc/$pid/smaps will not
> destroy transparent huge pages, tell how much of the VMA is
> actually mapped with them.
> 
> This way, we can make sure that we're getting THPs where we
> expect to see them.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
