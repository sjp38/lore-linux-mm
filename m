Received: by wf-out-1314.google.com with SMTP id 28so1054868wfc.11
        for <linux-mm@kvack.org>; Fri, 24 Oct 2008 11:59:28 -0700 (PDT)
Message-ID: <2f11576a0810241159i677f67a0x7dce373bee7cd1d6@mail.gmail.com>
Date: Sat, 25 Oct 2008 03:59:27 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
In-Reply-To: <4901DC5E.5040908@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <878wsigp2e.fsf_-_@saeurebad.de> <87zlkuj10z.fsf@saeurebad.de>
	 <20081024213527.492B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <4901DC5E.5040908@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>> Well, time-wise not sooo much of an improvement.  But given the
>>> massively decreased LRU-rotation [ http://hannes.saeurebad.de/madvseq/ ]
>>
>> My first impression, this result mean the patch is not so useful.
>> But anyway, I mesured it again because I think Nick's opinion is very
>> reasonable and I don't know your mesurement condition so detail.
>
> It may not make much of a difference if the MADV_SEQUENTIAL
> program is the only thing running on the system.
>
> However, the goal of MADV_SEQUENTIAL is to make sure that a
> streaming mapping does not kick the data from other programs
> out of memory.  The patch should take care of that very well.


Well, my second test(following) indicate it IMO.

> 2. MADV_SEQUENTIAL vs dbench
>
>                        mmotm1022   + the patch
>  ==============================================================
>  mm_sync_madv_cp       6:29        6:19           (min:sec)
>  dbench throughput     11.633      14.4045        (MB/s)
>  dbench latency        65628       18565          (ms)


So, I think the code of this patch is good, but I guess his mesurement
way isn't so good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
