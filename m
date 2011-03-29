Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 458488D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:53:33 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p2TKrTSf013709
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:53:29 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by wpaz9.hot.corp.google.com with ESMTP id p2TKq008013027
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:53:28 -0700
Received: by qyk10 with SMTP id 10so634901qyk.18
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:53:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329204550.GN12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
	<4D91FC2D.4090602@redhat.com>
	<20110329190520.GJ12265@random.random>
	<BANLkTi=cysSDYUaRX3nXHgKmEB9acjCMsA@mail.gmail.com>
	<20110329204550.GN12265@random.random>
Date: Tue, 29 Mar 2011 13:53:27 -0700
Message-ID: <BANLkTimv2HWwGf=RicANRv8ouDbqazAysQ@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Tue, Mar 29, 2011 at 1:45 PM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> On Tue, Mar 29, 2011 at 01:35:24PM -0700, Ying Han wrote:
>> In page reclaim, I would like to discuss on the magic "8" *
>> high_wmark() in balance_pgdat(). I recently found the discussion on
>> thread "too big min_free_kbytes", where I didn't find where we proved
>> it is still a problem or not. This might not need reserve time slot,
>> but something I want to learn more on.
>
> That is merged in 2.6.39-rc1. It's hopefully working good enough. We
> still use high+balance_gap but the balance_gap isn't high*8 anymore. I
> still think the balance_gap may as well be zero but the gap now is
> small enough (not 600M on 4G machine anymore) that it's ok and this
> was a safer change.
>
> This is an LRU ordering issue to try to keep the lru balance across
> the zones and not just rotate a lot a single one. I think it can be
> covered in the LRU ordering topic too. But we could also expand it to
> a different slot if we expect too many issues to showup in that
> slot... Hugh what's your opinion?

Yes, that is what I got from the thread discussion and thank you for
confirming that. Guess my question is :

Do we need to do balance across zones by giving the fact that each
zone does its own balancing?
What is the problem we saw without doing the cross-zone balancing?

I don't have data to back-up either way, and that is something I am
interested too :)

--Ying


>
> The subtopics that comes to mind for that topic so far would be:
>
> - reclaim latency
> - compaction issues (Mel)
> - lru ordering altered by compaction/migrate/khugepaged or other
> =A0features requiring lru page isolation (Minchan)
> - lru rotation balance across zones in kswapd (balance_gap) (Ying)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
