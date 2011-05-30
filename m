Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1164A6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 20:35:30 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2096319qwa.14
        for <linux-mm@kvack.org>; Sun, 29 May 2011 17:35:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306701498-10846-1-git-send-email-cesarb@cesarb.net>
References: <1306701498-10846-1-git-send-email-cesarb@cesarb.net>
Date: Mon, 30 May 2011 09:35:29 +0900
Message-ID: <BANLkTikX+dKsdwGOxG10Q2LVd_rCxEBRHw@mail.gmail.com>
Subject: Re: [PATCH] cleancache: use __read_mostly for cleancache_enabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Jan Beulich <JBeulich@novell.com>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org

On Mon, May 30, 2011 at 5:38 AM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> The global variable cleancache_enabled is read often but written to
> rarely. Use __read_mostly to prevent it being on the same cacheline as
> another variable which is written to often, which would cause cacheline
> bouncing.
>
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
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
