Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 042196B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 05:23:05 -0400 (EDT)
Received: by widfa3 with SMTP id fa3so17895627wid.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:23:04 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id kz6si25802687wjc.27.2015.08.31.02.23.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 02:23:03 -0700 (PDT)
Received: by widfa3 with SMTP id fa3so17894685wid.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:23:02 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:23:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
Message-ID: <20150831092300.GE29723@dhcp22.suse.cz>
References: <1440787391-30298-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440787391-30298-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: mtk.manpages@gmail.com, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 28-08-15 14:43:11, Eric B Munson wrote:
> Update the mlock.2 man page with information on mlock2() and the new
> mlockall() flag MCL_ONFAULT.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

I am not familiar with the format much so I am just looking at the text
and that looks reasonable to me. Just one note below:

> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: linux-man@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  man2/mlock.2  | 109 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  man2/mlock2.2 |   1 +
>  2 files changed, 97 insertions(+), 13 deletions(-)
>  create mode 100644 man2/mlock2.2
> 
> diff --git a/man2/mlock.2 b/man2/mlock.2
> index 79c544d..8f51926 100644
> --- a/man2/mlock.2
> +++ b/man2/mlock.2
[...]
> +The
> +.I flags
> +argument can be either 0 or the following constant:
> +.TP 1.2i
> +.B MLOCK_ONFAULT
> +Lock pages that are currently resident and mark the entire range to have
> +pages locked when they are faulted in.

@faulted in@populated by the page fault@.

would be probably better.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
