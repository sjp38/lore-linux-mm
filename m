Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 401396B00F0
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 14:54:15 -0400 (EDT)
Received: by dadq36 with SMTP id q36so581309dad.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 11:54:14 -0700 (PDT)
Message-ID: <4F98485F.5030405@gmail.com>
Date: Wed, 25 Apr 2012 14:54:23 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rename is_mlocked_vma() to mlocked_vma_newpage()
References: <1335375955-32037-1-git-send-email-yinghan@google.com>
In-Reply-To: <1335375955-32037-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(4/25/12 1:45 PM), Ying Han wrote:
> Andrew pointed out that the is_mlocked_vma() is misnamed. A function
> with name like that would expect bool return and no side-effects.
> 
> Since it is called on the fault path for new page, rename it in this
> patch.
> 
> Signed-off-by: Ying Han<yinghan@google.com>

Good.
 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
