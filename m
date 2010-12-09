Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8AF6F6B008C
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 11:09:40 -0500 (EST)
Received: by iwn1 with SMTP id 1so3901487iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 08:09:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291905904-32716-1-git-send-email-tklauser@distanz.ch>
References: <1291905904-32716-1-git-send-email-tklauser@distanz.ch>
Date: Fri, 10 Dec 2010 01:09:34 +0900
Message-ID: <AANLkTimNdZ4qRRFfrMUnmyZgPuoe2M8eVdCQykg1Dk-u@mail.gmail.com>
Subject: Re: [PATCH] vmalloc: Remove redundant unlikely()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Tobias Klauser <tklauser@distanz.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 11:45 PM, Tobias Klauser <tklauser@distanz.ch> wrote:
> IS_ERR() already implies unlikely(), so it can be omitted here.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
