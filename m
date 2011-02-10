Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D12F8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 23:56:26 -0500 (EST)
Received: by wyj26 with SMTP id 26so991220wyj.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 20:56:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTik36rhvou2Bu99LMkAXx+BYQJysPxZG1gAAJwyv@mail.gmail.com>
References: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com>
 <20110210085823.2f99b81c.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikdBhSWAoP6TDRExSV2rHmWDkEc0foSKvqJt=tx@mail.gmail.com>
 <AANLkTik36rhvou2Bu99LMkAXx+BYQJysPxZG1gAAJwyv@mail.gmail.com>
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Date: Thu, 10 Feb 2011 13:56:03 +0900
Message-ID: <AANLkTi=n1hvQKBOcLtP1FY07x8yBEvawH3mKYeGyR0xX@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix out-of-date comments which refers non-existent functions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 1:44 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Feb 10, 2011 at 12:58 PM, Ryota Ozaki <ozaki.ryota@gmail.com> wro=
te:
>> On Thu, Feb 10, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> On Wed, =A09 Feb 2011 23:42:17 +0900
>>> Ryota Ozaki <ozaki.ryota@gmail.com> wrote:
>>>
>>>> From: Ryota Ozaki <ozaki.ryota@gmail.com>
>>>>
>>>> do_file_page and do_no_page don't exist anymore, but some comments
>>>> still refers them. The patch fixes them by replacing them with
>>>> existing ones.
>>>>
>>>> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
>>>
>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Thanks, Kamezawa-san.
>>
>>>
>>> It seems there are other ones ;)
>>> =3D=3D
>>> =A0 =A0Searched full:do_no_page (Results 1 - 3 of 3) sorted by relevanc=
y
>>>
>>> =A0/linux-2.6-git/arch/alpha/include/asm/
>>> H A D =A0 cacheflush.h =A0 =A066 /* This is used only in do_no_page and=
 do_swap_page. */
>>> =A0/linux-2.6-git/arch/avr32/mm/
>>> H A D =A0 cache.c =A0 =A0 =A0 =A0 116 * This one is called from do_no_p=
age(), do_swap_page() and install_page().
>>> =A0/linux-2.6-git/mm/
>>> H A D =A0 memory.c =A0 =A0 =A0 =A02121 * and do_anonymous_page and do_n=
o_page can safely check later on).
>>> 2319 * do_no_page is protected similarly.
>>
>> Nice catch :-) Cloud I assemble all fixes into one patch?
>>
>> =A0ozaki-r
>>
>
> When you resend the patch, Please Cc Jiri Kosina <trivial@kernel.org>

OK, will do.

  ozaki-r

>
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
