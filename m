Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D1BFE6B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 15:13:10 -0500 (EST)
Received: by eekc13 with SMTP id c13so1232809eek.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:13:09 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
 <op.v9hahmw23l0zgt@mpn-glaptop> <874nuy31hw.fsf@caffeine.danplanet.com>
Date: Fri, 10 Feb 2012 21:13:07 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9hbr5xx3l0zgt@mpn-glaptop>
In-Reply-To: <874nuy31hw.fsf@caffeine.danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 10 Feb 2012 20:57:31 +0100, Dan Smith <danms@us.ibm.com> wrote:
> MN> Commit message says about walk_pte_range() but commit changes
> MN> walk_page_range().
>
> Yep, the issue occurs in walk_pte_range().

OK, it wasn't immediately obvious for me that while loop in walk_page_ra=
nge()
will actually recover if arguments are not aligned (since pgd_addr_end()=
 caps
returned value).

> The goal was to ensure that
> the external interface to it (which is walk_page_range()) does the che=
ck
> and avoids doing the walk entirely. I think the expectation is that
> walk_page_range() is used on aligned addresses. If we put the check in=

> walk_pte_range() then only walks with a pte_entry handler would fail o=
n
> unaligned addresses, which is potentially confusing.
>
> MN> So why not change the condition to addr < end?
>
> That would work, of course, but seems sloppier and less precise. The
> existing code was clearly written expecting to walk aligned addresses.=


Fair enough.

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
