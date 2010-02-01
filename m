Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 04FB66B007D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 10:26:47 -0500 (EST)
Received: by pzk7 with SMTP id 7so4459621pzk.12
        for <linux-mm@kvack.org>; Mon, 01 Feb 2010 07:26:46 -0800 (PST)
Subject: Re: [PATCH -mm] rmap: remove obsolete check from
 __page_check_anon_rmap
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100128014312.47c5045d@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
	 <20100128014312.47c5045d@annuminas.surriel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Feb 2010 00:26:39 +0900
Message-ID: <1265037999.20322.33.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-28 at 01:43 -0500, Rik van Riel wrote:
> When an anonymous page is inherited from a parent process, the
> vma->anon_vma can differ from the page anon_vma.  This can trip
> up __page_check_anon_rmap, which is indirectly called from
> do_swap_page().
> 
> Remove that obsolete check to prevent an oops.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim>

Hmm, too late. 

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
