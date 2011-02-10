Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C84C08D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 00:07:46 -0500 (EST)
Received: by iyi20 with SMTP id 20so957147iyi.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 21:07:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297313788-10905-1-git-send-email-ozaki.ryota@gmail.com>
References: <1297313788-10905-1-git-send-email-ozaki.ryota@gmail.com>
Date: Thu, 10 Feb 2011 14:07:43 +0900
Message-ID: <AANLkTikFEjeVJ2HY_KTv29y63bt_+8SwWm7K3Ywdw570@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix out-of-date comments which refers non-existent functions
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Jiri Kosina <trivial@kernel.org>

On Thu, Feb 10, 2011 at 1:56 PM, Ryota Ozaki <ozaki.ryota@gmail.com> wrote:
> From: Ryota Ozaki <ozaki.ryota@gmail.com>
>
> do_file_page and do_no_page don't exist anymore, but some comments
> still refers them. The patch fixes them by replacing them with
> existing ones.
>
> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Jiri Kosina <trivial@kernel.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
