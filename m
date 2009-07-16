Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DFE0C6B005D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:01:41 -0400 (EDT)
Received: by gxk3 with SMTP id 3so6942337gxk.14
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:01:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090715201654.550cb640.akpm@linux-foundation.org>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
	 <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
	 <20090715201654.550cb640.akpm@linux-foundation.org>
Date: Thu, 16 Jul 2009 13:01:37 +0900
Message-ID: <28c262360907152101y15d7edc6m3e3cf4d3473b0008@mail.gmail.com>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 12:16 PM, Andrew
Morton<akpm@linux-foundation.org> wrote:
> On Thu, 16 Jul 2009 09:52:34 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro=
@jp.fujitsu.com> wrote:
>
>> =C2=A0 =C2=A0 =C2=A0 if (file)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, =
NR_ACTIVE_FILE, -pgmoved);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, =
NR_ACTIVE_FILE, -nr_taken);
>> =C2=A0 =C2=A0 =C2=A0 else
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, =
NR_ACTIVE_ANON, -pgmoved);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, =
NR_ACTIVE_ANON, -nr_taken);
>
> we could have used __sub_zone_page_state() there.

Yes. It can be changed all at once by separate patches. :)



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
