From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <878wsigp2e.fsf_-_@saeurebad.de> <87zlkuj10z.fsf@saeurebad.de>
	<20081024213527.492B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<4901DC5E.5040908@redhat.com>
Date: Fri, 24 Oct 2008 18:15:27 +0200
In-Reply-To: <4901DC5E.5040908@redhat.com> (Rik van Riel's message of "Fri, 24
	Oct 2008 10:31:58 -0400")
Message-ID: <87myguhsv4.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> writes:

> KOSAKI Motohiro wrote:
>>> mmotm:
>>>     normal  user: 1.775000s [0.053307] system: 9.620000s [0.135339] total: 98.875000s [0.613956]
>>>    madvise  user: 2.552500s [0.041307] system: 9.442500s [0.075980] total: 73.937500s [0.734170]
>>> mmotm+patch:
>>>     normal  user: 1.850000s [0.013540] system: 9.760000s [0.047081] total: 99.250000s [0.569386]
>>>    madvise  user: 2.547500s [0.014930] system: 8.865000s [0.055000] total: 71.897500s [0.144763]
>>>
>>> Well, time-wise not sooo much of an improvement.  But given the
>>> massively decreased LRU-rotation [ http://hannes.saeurebad.de/madvseq/ ]
>>
>> My first impression, this result mean the patch is not so useful.
>> But anyway, I mesured it again because I think Nick's opinion is very
>> reasonable and I don't know your mesurement condition so detail.
>
> It may not make much of a difference if the MADV_SEQUENTIAL
> program is the only thing running on the system.

As said, I had a big dd running in the background.  The box has only
768mb RAM, so there really was VM activity going on.

And given this small standard deviations, the numbers seem pretty
stable.  Even if I had taken more samples, I highly doubt that they
would have looked much different.

Perhaps still not enough VM pressure...

        Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
