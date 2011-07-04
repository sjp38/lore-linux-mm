Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C21D89000C2
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 23:10:44 -0400 (EDT)
From: "Dmitry Fink (Palm GBU)" <Dmitry.Fink@palm.com>
Date: Sun, 3 Jul 2011 20:10:32 -0700
Subject: Re: [PATCH 1/1] mmap: Don't count shmem pages as free in
 __vm_enough_memory
Message-ID: <CA367A4F.1479D%dmitry.fink@palm.com>
In-Reply-To: <CAEwNFnAYAWy4tabCuzGUwXjLpZVbxhKMmPXnhmCuH5pckOXBRw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>, Dmitry Fink <finikk@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

If I understand the logic correctly, even systems with swap set to
OVERCOMMIT_GUESS are equally affected,
what we are trying to do here is count the amount of immediately available
and
"potentially" available space both in memory and in swap. shmem is not
immediately
available, but it is not potentially available either, even if we swap it
out, it will
just be relocated from memory into swap, total amount of immediate and
potentially
available memory is not going to be affected, so we shouldn't count it as
available
in the first place.

Dmitry

On 7/3/11 5:43 PM, "Minchan Kim" <minchan.kim@gmail.com> wrote:

>On Mon, Jul 4, 2011 at 4:39 AM, Dmitry Fink <finikk@gmail.com> wrote:
>> shmem pages can't be reclaimed and if they are swapped out
>> that doesn't affect the overall available memory in the system,
>> so don't count them along with the rest of the file backed pages.
>>
>> Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
>Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
>I am not sure the description is good. :(
>But I think this patch is reasonable.
>
>In swapless system,guessing overcommit can have a problem.
>And in current implementation of OVERCOMMIT_GUESS, we consider anon
>pages as empty space of swap so shmem pages should be accounted by
>that.
>
>--=20
>Kind regards,
>Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
