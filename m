Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id F27E86B00E2
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 06:13:03 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id m15so1356314wgh.3
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 03:13:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHO5Pa0srsWS6ukpxUo=EqCOxRmYa7c_7PDg1YPh7gcMGWPpaw@mail.gmail.com>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org> <CAHO5Pa0srsWS6ukpxUo=EqCOxRmYa7c_7PDg1YPh7gcMGWPpaw@mail.gmail.com>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Wed, 3 Apr 2013 12:12:42 +0200
Message-ID: <CAHO5Pa1we3FCoBTSHTO23tzCss4Z-AkZzoGxBYkTy7e5aYmcJw@mail.gmail.com>
Subject: Re: [RFC 1/4] mm: Per process reclaim
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>

> However, the interface is a quite blunt instrument. Would there be any
> virtue in extending it so that an address range could be written to

Here, I did mean to say "an *optional* address range.

Thanks,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
