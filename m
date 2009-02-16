Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E0C936B00B2
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 13:17:32 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so257141fgg.4
        for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:17:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090216153351.GB27520@cmpxchg.org>
References: <20090216142926.440561506@cmpxchg.org>
	 <20090216144725.976425091@cmpxchg.org>
	 <84144f020902160713y7341b2b4g8aa10919405ab82d@mail.gmail.com>
	 <20090216153351.GB27520@cmpxchg.org>
Date: Mon, 16 Feb 2009 20:17:31 +0200
Message-ID: <84144f020902161017s5439a4d8ra9792250243dd43f@mail.gmail.com>
Subject: Re: [patch 6/8] cifs: use kzfree()
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2009 at 5:33 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Here is the delta to fold into the above:
>
> [ btw, do these require an extra SOB?  If so:
>  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>
>  And for http://lkml.org/lkml/2009/2/16/184:
>  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org> ]

Looks good to me. As I like to see my name in the LWN stats articles,
consider the whole patch:

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
