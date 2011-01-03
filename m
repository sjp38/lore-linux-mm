Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 902C16B00BA
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 17:33:16 -0500 (EST)
Received: by iyj17 with SMTP id 17so13435088iyj.14
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 14:33:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101031400550.10636@chino.kir.corp.google.com>
References: <1294072249-2916-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1101031400550.10636@chino.kir.corp.google.com>
Date: Tue, 4 Jan 2011 07:33:15 +0900
Message-ID: <AANLkTinb+W-hByy18tko8NFtYYzQonABps0gi7+7kQ5R@mail.gmail.com>
Subject: Re: [PATCH] writeback: avoid unnecessary determine_dirtyable_memory call
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 4, 2011 at 7:03 AM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 4 Jan 2011, Minchan Kim wrote:
>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index fc93802..c340536 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -390,9 +390,12 @@ void global_dirty_limits(unsigned long *pbackground=
, unsigned long *pdirty)
>> =A0{
>> =A0 =A0 =A0 unsigned long background;
>> =A0 =A0 =A0 unsigned long dirty;
>> - =A0 =A0 unsigned long available_memory =3D determine_dirtyable_memory(=
);
>> + =A0 =A0 unsigned long available_memory;
>
> You need unsigned long uninitialized_var(available_memory) to avoid the
> warning.

Yes. It's my fault. Andrew already fixed it.
Thanks, David.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
