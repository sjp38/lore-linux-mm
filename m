Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8E7816B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 19:52:18 -0400 (EDT)
Received: by yenm8 with SMTP id m8so5455861yen.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 16:52:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1203261346360.3443@eggly.anvils>
References: <1332777965-2534-1-git-send-email-consul.kautuk@gmail.com>
	<alpine.LSU.2.00.1203261346360.3443@eggly.anvils>
Date: Mon, 26 Mar 2012 19:52:17 -0400
Message-ID: <CAFPAmTQdud0rxbXt92zpRa+AmyNX8CKf=99X71VXvX9vteEC9g@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: replace if(mm) check with BUG_ON(!mm)
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,

Thanks for the review.

I have sent another patch for this with changed subject and your changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
