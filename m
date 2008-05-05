Received: by rv-out-0708.google.com with SMTP id f25so798157rvb.26
        for <linux-mm@kvack.org>; Mon, 05 May 2008 01:32:38 -0700 (PDT)
Message-ID: <44c63dc40805050132s602874eci66d60eaf9bbe9d57@mail.gmail.com>
Date: Mon, 5 May 2008 17:32:38 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
In-Reply-To: <2f11576a0805050124q5b91ff3dm70918f80017cb936@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40805042221s4eb347acu6e7d86310696825f@mail.gmail.com>
	 <2f11576a0805050124q5b91ff3dm70918f80017cb936@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I see.

My gmail client hide that contents.
I am sorry :-)

On Mon, May 5, 2008 at 5:24 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> >  >  +       /* in some situation (e.g. hibernation), shrink processing shouldn't be
> >  >  +          cut off even though large memory freeded.  */
> >  >  +       if (!sc->may_cut_off)
> >  >  +               goto shrinking;
> >  >  +
> >
> >  where do you initialize may_cut_off ?
> >  Current Implementation, may_cut_off is always "0" so always goto shrinking
>
> please see try_to_free_pages :)
>



-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
