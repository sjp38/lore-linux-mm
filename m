Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4EB616B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 07:17:24 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so820172wfa.11
        for <linux-mm@kvack.org>; Sat, 14 Mar 2009 04:17:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090313173348.10169.31420.stgit@warthog.procyon.org.uk>
References: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
	 <20090313173348.10169.31420.stgit@warthog.procyon.org.uk>
Date: Sat, 14 Mar 2009 20:17:22 +0900
Message-ID: <2f11576a0903140417w4caffda9q76e4662c68c6b9fc@mail.gmail.com>
Subject: Re: [PATCH 1/2] NOMMU: There is no mlock() for NOMMU, so don't
	provide the bits
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: minchan.kim@gmail.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

2009/3/14 David Howells <dhowells@redhat.com>:
> The mlock() facility does not exist for NOMMU since all mappings are
> effectively locked anyway, so we don't make the bits available when they're
> not useful.
>
> Signed-off-by: David Howells <dhowells@redhat.com>

Oh, your patch is more cleaner way.
Thanks!
   Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
