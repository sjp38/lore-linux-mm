Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6D956B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 20:56:41 -0500 (EST)
Received: by pzk36 with SMTP id 36so10383909pzk.23
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 17:56:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1265976059-7459-7-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
	 <1265976059-7459-7-git-send-email-mel@csn.ul.ie>
Date: Fri, 19 Feb 2010 10:56:40 +0900
Message-ID: <28c262361002181756i3dc430bdtdc506b54362a40ce@mail.gmail.com>
Subject: Re: [PATCH 06/12] Add /proc trigger for memory compaction
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 9:00 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> value is written to the file, all zones are compacted. The expected user
> of such a trigger is a job scheduler that prepares the system before the
> target application runs.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
