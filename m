Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id CE5F96B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 04:44:16 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M3S004ESTL6Y3I0@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 May 2012 17:44:14 +0900 (KST)
Received: from NOINKIDAE02 ([165.213.219.102])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M3S00EX9TLQ2910@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 10 May 2012 17:44:14 +0900 (KST)
From: Inki Dae <inki.dae@samsung.com>
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-3-git-send-email-inki.dae@samsung.com>
 <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
 <001501cd2e4d$c7dbc240$579346c0$%dae@samsung.com>
 <4FAB4AD8.2010200@kernel.org>
 <002401cd2e7a$1e8b0ed0$5ba12c70$%dae@samsung.com>
 <4FAB68CF.8000404@kernel.org>
 <CAAQKjZM0a-Lg8KYwWi+LwAXJPFYLKqWaKbuc4iUGVKyoStXu_w@mail.gmail.com>
 <4FAB782C.306@kernel.org>
In-reply-to: <4FAB782C.306@kernel.org>
Subject: RE: [PATCH 2/2 v3] drm/exynos: added userptr feature.
Date: Thu, 10 May 2012 17:44:14 +0900
Message-id: <003301cd2e89$13f78c00$3be6a400$%dae@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'InKi Dae' <daeinki@gmail.com>
Cc: 'Jerome Glisse' <j.glisse@gmail.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org


> -----Original Message-----
> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Thursday, May 10, 2012 5:11 PM
> To: InKi Dae
> Cc: Inki Dae; Jerome Glisse; airlied@linux.ie; dri-
> devel@lists.freedesktop.org; kyungmin.park@samsung.com;
> sw0312.kim@samsung.com; linux-mm@kvack.org
> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
> 
> On 05/10/2012 04:59 PM, InKi Dae wrote:
> 
> > 2012/5/10, Minchan Kim <minchan@kernel.org>:
> >> On 05/10/2012 03:57 PM, Inki Dae wrote:
> >>
> >>>
> >>>
> >>>> -----Original Message-----
> >>>> From: Minchan Kim [mailto:minchan@kernel.org]
> >>>> Sent: Thursday, May 10, 2012 1:58 PM
> >>>> To: Inki Dae
> >>>> Cc: 'Jerome Glisse'; airlied@linux.ie; dri-
> devel@lists.freedesktop.org;
> >>>> kyungmin.park@samsung.com; sw0312.kim@samsung.com; linux-mm@kvack.org
> >>>> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
> >>>>
> >>>> On 05/10/2012 10:39 AM, Inki Dae wrote:
> >>>>
> >>>>> Hi Jerome,
> >>>>>
> >>>>>> -----Original Message-----
> >>>>>> From: Jerome Glisse [mailto:j.glisse@gmail.com]
> >>>>>> Sent: Wednesday, May 09, 2012 11:46 PM
> >>>>>> To: Inki Dae
> >>>>>> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org;
> >>>>>> kyungmin.park@samsung.com; sw0312.kim@samsung.com; linux-
> mm@kvack.org
> >>>>>> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
> >>>>>>
> >>>>>> On Wed, May 9, 2012 at 2:17 AM, Inki Dae <inki.dae@samsung.com>
> wrote:
> >>>>>>> this feature is used to import user space region allocated by
> >>>>>>> malloc()
> >>>>>> or
> >>>>>>> mmaped into a gem. and to guarantee the pages to user space not to
> be
> >>>>>>> swapped out, the VMAs within the user space would be locked and
> then
> >>>>>> unlocked
> >>>>>>> when the pages are released.
> >>>>>>>
> >>>>>>> but this lock might result in significant degradation of system
> >>>>>> performance
> >>>>>>> because the pages couldn't be swapped out so we limit user-desired
> >>>>>> userptr
> >>>>>>> size to pre-defined.
> >>>>>>>
> >>>>>>> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> >>>>>>> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> >>>>>>
> >>>>>>
> >>>>>> Again i would like feedback from mm people (adding cc). I am not
> sure
> >>>>>
> >>>>> Thank you, I missed adding mm as cc.
> >>>>>
> >>>>>> locking the vma is the right anwser as i said in my previous mail,
> >>>>>> userspace can munlock it in your back, maybe VM_RESERVED is better.
> >>>>>
> >>>>> I know that with VM_RESERVED flag, also we can avoid the pages from
> >>>> being
> >>>>> swapped out. but these pages should be unlocked anytime we want
> because
> >>>> we
> >>>>> could allocate all pages on system and lock them, which in turn, it
> may
> >>>>> result in significant deterioration of system performance.(maybe
> other
> >>>>> processes requesting free memory would be blocked) so I used
> VM_LOCKED
> >>>> flags
> >>>>> instead. but I'm not sure this way is best also.
> >>>>>
> >>>>>> Anyway even not considering that you don't check at all that
> process
> >>>>>> don't go over the limit of locked page see mm/mlock.c
> RLIMIT_MEMLOCK
> >>>>>
> >>>>> Thank you for your advices.
> >>>>>
> >>>>>> for how it's done. Also you mlock complete vma but the userptr you
> get
> >>>>>> might be inside say 16M vma and you only care about 1M of userptr,
> if
> >>>>>> you mark the whole vma as locked than anytime a new page is fault
> in
> >>>>>> the vma else where than in the buffer you are interested then it
> got
> >>>>>> allocated for ever until the gem buffer is destroy, i am not sure
> of
> >>>>>> what happen to the vma on next malloc if it grows or not (i would
> >>>>>> think it won't grow at it would have different flags than new
> >>>>>> anonymous memory).
> >>>>
> >>>>
> >>>> I don't know history in detail because you didn't have sent full
> patches
> >>>> to linux-mm and
> >>>> I didn't read the below code, either.
> >>>> Just read your description and reply of Jerome. Apparently, there is
> >>>> something I missed.
> >>>>
> >>>> Your goal is to avoid swap out some user pages which is used in
> kernel
> >>>> at
> >>>> the same time. Right?
> >>>> Let's use get_user_pages. Is there any issue you can't use it?
> >>>> It increases page count so reclaimer can't swap out page.
> >>>> Isn't it enough?
> >>>> Marking whole VMA into MLCOKED is overkill.
> >>>>
> >>>
> >>> As I mentioned, we are already using get_user_pages. as you said, this
> >>> function increases page count but just only things to the user address
> >>> space
> >>> cpu already accessed. other would be allocated by page fault hander
> once
> >>> get_user_pages call. if so... ok, after that refcount(page->_count) of
> >>> the
> >>
> >>
> >> Not true. Look __get_user_pages.
> >> It handles case you mentioned by handle_mm_fault.
> >> Do I miss something?
> >>
> >
> > let's assume that one application want to allocate user space memory
> > region using malloc() and then write something on the region. as you
> > may know, user space buffer doen't have real physical pages once
> > malloc() call so if user tries to access the region then page fault
> > handler would be triggered
> 
> 
> Understood.
> 
> > and then in turn next process like swap in to fill physical frame number
> into entry of the page faulted.
> 
> 
> Sorry, I can't understand your point due to my poor English.
> Could you rewrite it easiliy? :)
> 

Simply saying, handle_mm_fault would be called to update pte after finding
vma and checking access right. and as you know, there are many cases to
process page fault such as COW or demand paging.

Thanks,
Inki Dae

> Thanks.
> 
> > of course,if user never access the buffer and requested userptr then
> 
> > handle_mm_fault would be called by __get_user_pages. please give me
> > any comments if there is my missing point.
> >
> > Thanks,
> > Inki Dae
> >
> >
> >>> pages user already accessed would have 2 and just 1 for other all
> pages.
> >>> so
> >>> we may have to consider only pages never accessed by cpu to be locked
> to
> >>> avoid from swapped out.
> >>>
> >>> Thanks,
> >>> Inki Dae
> >>>
> >>>> --
> >>>> Kind regards,
> >>>> Minchan Kim
> >>>
> >>> --
> >>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>> the body to majordomo@kvack.org.  For more info on Linux MM,
> >>> see: http://www.linux-mm.org/ .
> >>> Fight unfair telecom internet charges in Canada: sign
> >>> http://stopthemeter.ca/
> >>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>
> >>
> >>
> >>
> >> --
> >> Kind regards,
> >> Minchan Kim
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Fight unfair telecom internet charges in Canada: sign
> >> http://stopthemeter.ca/
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> 
> 
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
