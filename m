Received: by rv-out-0708.google.com with SMTP id f25so799294rvb.26
        for <linux-mm@kvack.org>; Mon, 05 May 2008 01:37:10 -0700 (PDT)
Message-ID: <44c63dc40805050137g372bec5cr6d02eaf35b945629@mail.gmail.com>
Date: Mon, 5 May 2008 17:37:10 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [-mm][PATCH 3/5] change function prototype of shrink_zone()
In-Reply-To: <2f11576a0805050131k6df2c0d6r93edb4893ad655b9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215718.8F5B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40805042142k2e5bc366mffa9e0a22fbe94c9@mail.gmail.com>
	 <2f11576a0805050131k6df2c0d6r93edb4893ad655b9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

OK. I see
I seemed to be in a hurry without looking over following patches.

On Mon, May 5, 2008 at 5:31 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
> >  >  +       sc->nr_reclaimed += nr_reclaimed;
> >  >         throttle_vm_writeout(sc->gfp_mask);
> >  >  -       return nr_reclaimed;
> >  >  +       return 0;
> >  >   }
> >
> >  I am not sure this is right.
> >  I might be wrong if this patch is depended on another patch.
> >
> >  As I see, shrink_zone always return 0 in your patch.
>
> Yeah, this patch is just preparetion change of [4/5].
> I use EAGAIN at [4/5].
>
>
> >  If it is right, I think that return value is useless. It is better
> >  that we change function return type to "void"
> >  Also, we have to change functions that call shrink_zone properly. ex)
> >  balance_pgdat, __zone_reclaim
> >  That functions still use number of shrink_zone's reclaim page
>
> this patch is not intent by solo usage.
> just intent to bisect friendly.
> thus, We need implement that following patch use freature only.
>
> Thanks!
>



-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
