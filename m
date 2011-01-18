Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DDE596B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:42:34 -0500 (EST)
Received: by iwn40 with SMTP id 40so212217iwn.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:42:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110118151402.29441705.akpm@linux-foundation.org>
References: <20110118151402.29441705.akpm@linux-foundation.org>
Date: Wed, 19 Jan 2011 08:42:32 +0900
Message-ID: <AANLkTimfA=x=Wvh_+BcZpCyjHQkG1bnvhCPq1yT=aFT8@mail.gmail.com>
Subject: Re: mm-deactivate-invalidated-pages.patch
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ben Gamari <bgamari.foss@gmail.com>, Steven Barrett <damentz@liquorix.net>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 8:14 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> I haven't merged this. =A0What do we think its status/desirability is?
> Testing results?

Please, revert this.
This patch is old. I have sent several versions to mm.
It's a last version.
http://www.spinics.net/lists/linux-mm/msg12492.html
Testing result is following as.
http://marc.info/?l=3Dlinux-kernel&m=3D129225429008739&w=3D3

Some people already applied it into their kernel and they said to me
that this patch series solve response problem in his computer. It's a
real issue.
But unfortunately they reported a problem to me so I sent a patch.
So I have to resend this series with my one fix and with test result.
Hmm.. maybe I need a enough time to rebase and retest.

I will resend it after you release mmotm.


>
> I have a note against it: "When PageActive is unset, we need to change
> cgroup lru too.". =A0Did that get addressed?

Yes. [add/del]_page_to_lru_list already does it.

Thanks, Andrew.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
