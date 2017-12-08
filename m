Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 864696B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 23:37:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i71so440608wmd.9
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 20:37:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h140sor186714wmd.1.2017.12.07.20.37.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 20:37:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJuCfpHV=O4Kq4jppeMu7A==N37VhmXvHYRYvERmxQVeEZ=jUQ@mail.gmail.com>
References: <20171206192026.25133-1-surenb@google.com> <20171207083436.GC20234@dhcp22.suse.cz>
 <CAJuCfpHV=O4Kq4jppeMu7A==N37VhmXvHYRYvERmxQVeEZ=jUQ@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 7 Dec 2017 20:37:53 -0800
Message-ID: <CAJuCfpFkcCrx4VbQPEFGJfsRH0C7Jw1dXjqzhT86i26S7SsMKA@mail.gmail.com>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Content-Type: multipart/alternative; boundary="001a1145b3fe82ef47055fccbf15"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

--001a1145b3fe82ef47055fccbf15
Content-Type: text/plain; charset="UTF-8"

>
>
> According to my traces this 43ms could drop to the average of 11ms and
> worst case 25ms if throttle_direct_reclaim would return true when
> fatal signal is pending but I would like to hear your opinion about
> throttle_direct_reclaim logic.
>

Digging some more into this I realize my last statement might be incorrect.
Throttling in this situation might not help with the signal handling delay
because of the logic in __alloc_pages_slowpath. I'll have to experiment
with this first, please disregard that last statement for now.

--001a1145b3fe82ef47055fccbf15
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left=
:1px solid rgb(204,204,204);padding-left:1ex"><span class=3D"gmail-"><br>
According to my traces this 43ms could drop to the average of 11ms and<br>
worst case 25ms if throttle_direct_reclaim would return true when<br>
</span>fatal signal is pending but I would like to hear your opinion about<=
br>
throttle_direct_reclaim logic.<br></blockquote><div><br></div><div>Digging =
some more into this I realize my last statement might be incorrect. Throttl=
ing in this situation might not help with the signal handling delay because=
 of the logic in __alloc_pages_slowpath. I&#39;ll have to experiment with t=
his first, please disregard that last statement for now.</div><div><br></di=
v><div><br></div></div></div></div>

--001a1145b3fe82ef47055fccbf15--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
