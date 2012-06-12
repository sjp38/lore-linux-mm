Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 831D36B0072
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 12:49:35 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4659426ggm.14
        for <linux-mm@kvack.org>; Tue, 12 Jun 2012 09:49:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD6EDF4.3090208@kernel.org>
References: <1339468171-9880-1-git-send-email-hao.bigrat@gmail.com> <4FD6EDF4.3090208@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 12 Jun 2012 12:49:13 -0400
Message-ID: <CAHGf_=rh1iGFmHb90Cbx+CCJSKUxbp-A_XWd3y4EirZqoyN_WQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm: fix wrong order of operations in __lru_cache_add()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Robin Dong <hao.bigrat@gmail.com>, linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jun 12, 2012 at 3:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> It seems you forget Ccing relevant people. :)
> KOSAKI still might have a concern about this patch.

No problem. I might revisit this issue later. but I don't want to
block his patch.

 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
