Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C7EEA6B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 19:51:00 -0500 (EST)
Received: by gxk21 with SMTP id 21so1874102gxk.10
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 16:50:59 -0800 (PST)
Date: Mon, 2 Nov 2009 09:48:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCHv2 5/5][nit fix] vmscan Make consistent of reclaim bale
 out between do_try_to_free_page and shrink_zone
Message-Id: <20091102094825.50af0708.minchan.kim@barrios-desktop>
In-Reply-To: <20091102001210.F40D.A69D9226@jp.fujitsu.com>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
	<20091102001210.F40D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 00:13:04 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Fix small inconsistent of ">" and ">=".
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
