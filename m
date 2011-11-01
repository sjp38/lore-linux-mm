Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E8A746B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:07:02 -0400 (EDT)
Received: by faaf16 with SMTP id f16so64682faa.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 11:06:59 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
References: <20111018122109.GB6660@csn.ul.ie>
 <809d0a2afe624c06505e0df51e7657f66aaf9007.1319428526.git.mina86@mina86.com>
 <20111101150448.GD14998@csn.ul.ie>
Date: Tue, 01 Nov 2011 19:06:56 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v394luhl3l0zgt@mpn-glaptop>
In-Reply-To: <20111101150448.GD14998@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue, 01 Nov 2011 16:04:48 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> For the purposes of review, have a separate patch for moving
> isolate_freepages_block to another file that does not alter the
> function in any way. When the function is updated in a follow-on patch=
,
> it'll be far easier to see what has changed.

Will do.

> page_isolation.c may also be a better fit than page_alloc.c

Since isolate_freepages_block() is the only user of split_free_page(),
would it make sense to move split_free_page() to page_isolation.c as
well?  I sort of like the idea of making it static and removing from
header file.

> I confess I didn't read closely because of the mess in page_alloc.c bu=
t
> the intent seems fine.

No worries.  I just needed for a quick comment whether I'm headed the ri=
ght
direction. :)

> Hopefully there will be a new version of CMA posted that will be easie=
r
> to review.

I'll try and create the code no latter then on the weekend so hopefully
the new version will be sent next week.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
