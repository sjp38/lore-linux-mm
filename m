Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E63386B006C
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 18:33:12 -0500 (EST)
Received: by yenm10 with SMTP id m10so1184261yen.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:33:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111124001.7371.17791.stgit@zurg>
References: <20110729075837.12274.58405.stgit@localhost6>
	<20111111124001.7371.17791.stgit@zurg>
Date: Sat, 12 Nov 2011 08:33:10 +0900
Message-ID: <CAEwNFnBbyAVyQL1V9tz9gLTrP20ONXRyPGHLhV8f57gpJm8q5w@mail.gmail.com>
Subject: Re: [PATCH v3 2/4] mm: remove unused pagevec_free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Fri, Nov 11, 2011 at 10:40 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> It not exported and now nobody use it.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
