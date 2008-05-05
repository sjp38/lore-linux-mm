Received: by wa-out-1112.google.com with SMTP id m28so282523wag.8
        for <linux-mm@kvack.org>; Mon, 05 May 2008 01:24:20 -0700 (PDT)
Message-ID: <2f11576a0805050124q5b91ff3dm70918f80017cb936@mail.gmail.com>
Date: Mon, 5 May 2008 17:24:20 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
In-Reply-To: <44c63dc40805042221s4eb347acu6e7d86310696825f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40805042221s4eb347acu6e7d86310696825f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>  >  +       /* in some situation (e.g. hibernation), shrink processing shouldn't be
>  >  +          cut off even though large memory freeded.  */
>  >  +       if (!sc->may_cut_off)
>  >  +               goto shrinking;
>  >  +
>
>  where do you initialize may_cut_off ?
>  Current Implementation, may_cut_off is always "0" so always goto shrinking

please see try_to_free_pages :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
