Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 497558D0002
	for <linux-mm@kvack.org>; Fri, 11 May 2012 19:29:42 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5401929pbb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 16:29:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FAD99E1.4090600@gmail.com>
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
	<003301cd2e89$13f78c00$3be6a400$%dae@samsung.com>
	<4FAC0091.7070606@gmail.com>
	<4FAC623E.7090209@kernel.org>
	<4FAC7EBA.1080708@gmail.com>
	<CAH3drwb-HKmCbf6RxK5OEyAgukBTDLxt0Rf4ZNsygGuZ5SB=5g@mail.gmail.com>
	<4FAD829E.2030707@gmail.com>
	<CAH3drwYu_N5kOM1dSgJw8JNv2ScNkTPLZrRbzozrsF=D2=S=kA@mail.gmail.com>
	<4FAD99E1.4090600@gmail.com>
Date: Fri, 11 May 2012 19:29:41 -0400
Message-ID: <CAH3drwbTieeeAvdOt1d3drwZJh1+tACk8VkRszsDTryJBojHqg@mail.gmail.com>
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Inki Dae <inki.dae@samsung.com>, InKi Dae <daeinki@gmail.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org

On Fri, May 11, 2012 at 6:59 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> My point is this ioctl will be restricted to one user (Xserver if i
>> understand) and only this user, there is no fork in it so no need to
>> worry about fork, just setting the vma as locked will be enough.
>>
>> But i don't want people reading this driver suddenly think that what
>> it's doing is ok, it's not, it's hack and can never make to work
>> properly on a general case, that's why it needs a big comment stating,
>> stressing that. I just wanted to make sure Inki and Kyungmin
>> understood that this kind of ioctl should be restricted to carefully
>> selected user and that there is no way to make it general or reliable
>> outside that.
>
>
> first off, I'm not drm guy and then I don't intend to insist you. but if
> application don't use fork, get_user_pages() has no downside. I guess we
> don't need VM_LOCKED hack.
>
> but again, up to drm folks.

You need the VM_LOCKED hack to mare sure that the xorg vma still point
to the same page, afaict with get_user_pages pages can be migrated out
of the anonymous vma so the vma might point to new page, while old
page are still in use by the gpu and not recycle until their refcount
drop to 0.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
