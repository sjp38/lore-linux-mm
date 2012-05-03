Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D7D7D6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:07:48 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so242220gge.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 01:07:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA23A83.4040604@kernel.org>
References: <4F9E39F1.5030600@kernel.org>
	<CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
	<4F9E44AD.8020701@kernel.org>
	<CAOJsxLGd_-ZSxpY2sL8XqyiYxpnmYDJJ+Hfx-zi1Ty=-1igcLA@mail.gmail.com>
	<4F9E4F0A.8030900@kernel.org>
	<alpine.LFD.2.02.1205031019410.3686@tux.localdomain>
	<4FA23A83.4040604@kernel.org>
Date: Thu, 3 May 2012 11:07:47 +0300
Message-ID: <CAOJsxLHxLbzp+nfc72pzzyAe8W5w-phbHhREdJ7Mg5P9JHeF5A@mail.gmail.com>
Subject: Re: vmevent: question?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

On Thu, May 3, 2012 at 10:57 AM, Minchan Kim <minchan@kernel.org> wrote:
> Sorry for my poor explanation.
> My point is when userspace get vmevent_event by reading fd, it could enumerate
> several attribute all at once.
> Then, one of attribute(call A) made by vmevent_match in kernel and other attributes(call B, C, D)
> are just extra for convenience. Because there is time gap when kernel get attribute values, B,C,D could be stale.
> Then, how can user determine which event is really triggered? A or B or C or D?
> Which event really happens?

Right. Mark the matching values with something like
VMEVENT_ATTR_STATE_CAPTURED should be sufficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
