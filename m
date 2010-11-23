Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6B5D6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:09:43 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oAN29Z3O018880
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 18:09:35 -0800
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq1.eem.corp.google.com with ESMTP id oAN29X3O013081
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 18:09:34 -0800
Received: by qwc9 with SMTP id 9so1609255qwc.33
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 18:09:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122150642.eec5f776.akpm@linux-foundation.org>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
	<20101119142552.df0e351c.akpm@linux-foundation.org>
	<AANLkTi=EnNqEDoWn6OiR04TaTBskNEZx4z8MOAYH8nK1@mail.gmail.com>
	<20101122150642.eec5f776.akpm@linux-foundation.org>
Date: Mon, 22 Nov 2010 18:09:33 -0800
Message-ID: <AANLkTik6XxhGn=ASmyhxbq6wuCGtUaiW6s8rZBTQUu8_@mail.gmail.com>
Subject: Re: [PATCH] Pass priority to shrink_slab
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 3:06 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 19 Nov 2010 19:23:22 -0800
> Ying Han <yinghan@google.com> wrote:
>> Yes, and it would be much easier later to add a small feature (like this
>> one) w/o
>> touching so many files of the shrinkers. I am thinking if we can extend =
the
>> scan_control
>> from page reclaim and pass it down to the shrinker ?
>
> Yes, that might work. =A0All callers of shrink_slab() already have a
> scan_control on the stack, so passing all that extra info to the
> shrinkers (along with some extra fields if needed) is pretty cheap, and
> I don't see a great downside to exposing unneeded fields to the
> shrinkers, given they're already on the stack somewhere.

The only downside I can see is that it makes struct scan_control
public - it'll need to be declared in a public header file so that all
shrinkers can access it.

Maybe one way to mitigate this would be if we can make the shrinker
api take a *const* struct scan_control pointer as an argument, so that
it'll be clear that we expect the shrinkers to only read the
information in that struct.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
