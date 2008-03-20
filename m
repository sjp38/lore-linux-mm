Received: by py-out-1112.google.com with SMTP id f47so838319pye.20
        for <linux-mm@kvack.org>; Thu, 20 Mar 2008 00:43:22 -0700 (PDT)
Message-ID: <2f11576a0803200043p52d875ealcebe46d47d539628@mail.gmail.com>
Date: Thu, 20 Mar 2008 16:43:22 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [0/2] vmalloc: Add /proc/vmallocinfo to display mappings
In-Reply-To: <20080319150704.d3f090e6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318222701.788442216@sgi.com>
	 <20080319111943.0E1B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080319150704.d3f090e6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

>  > > Example:
>  > >
>  > > cat /proc/vmallocinfo
>
>  argh, please don't top-post.
>
>  (undoes it)

sorry, I don't do that at next.

>  > Great.
>  > it seems very useful.
>  > and, I found no bug.
>  >
>  > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
>  I was just about to ask whether we actually need the feature - I don't
>  recall ever having needed it, nor do I recall seeing anyone else need it.
>
>  Why is it useful?

to be honest, I tought this is merely good debug feature.
but crishtoph-san already explained it is more useful things.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
