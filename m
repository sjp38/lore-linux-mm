Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A650C6B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 05:43:14 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so7172481bkb.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 02:43:13 -0800 (PST)
Message-ID: <4F31003E.2090901@openvz.org>
Date: Tue, 07 Feb 2012 14:43:10 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH BUGFIX] mm: fix find_get_page() for shmem exceptional
 entries
References: <20120207103121.28345.28611.stgit@zurg>
In-Reply-To: <20120207103121.28345.28611.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Bug was added in commit v3.0-7291-g8079b1c (mm: clarify the radix_tree exceptional cases)
So, v3.1 and v3.2 affected.

Konstantin Khlebnikov wrote:
> It should return NULL, otherwise the caller will be very surprised.
>
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   mm/filemap.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 518223b..ca98cb5 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -693,6 +693,7 @@ repeat:
>   			 * here as an exceptional entry: so return it without
>   			 * attempting to raise page count.
>   			 */
> +			page = NULL;
>   			goto out;
>   		}
>   		if (!page_cache_get_speculative(page))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
