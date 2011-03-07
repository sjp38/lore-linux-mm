Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 164288D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 05:35:20 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p27AZHXg002057
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 02:35:18 -0800
Received: from gye5 (gye5.prod.google.com [10.243.50.5])
	by hpaq14.eem.corp.google.com with ESMTP id p27AZ6Fw024526
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 02:35:16 -0800
Received: by gye5 with SMTP id 5so1899143gye.38
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 02:35:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
	<AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
Date: Mon, 7 Mar 2011 02:35:15 -0800
Message-ID: <AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com>
Subject: Re: THP, rmap and page_referenced_one()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

There is also the issue that *mapcount will be decremented even if the
pmd turns out not to point to the given page. page_referenced() will
stop looking at rmap's candidate mappings once the refcount hits zero,
so the decrement will cause an actual mapping to be ignored.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
