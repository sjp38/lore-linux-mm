Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEE7F6B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 05:56:00 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3237845qwa.14
        for <linux-mm@kvack.org>; Tue, 12 Jul 2011 02:55:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E1C1684.4090706@jp.fujitsu.com>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
	<1310389274-13995-2-git-send-email-mgorman@suse.de>
	<CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
	<4E1C1684.4090706@jp.fujitsu.com>
Date: Tue, 12 Jul 2011 18:55:58 +0900
Message-ID: <CAEwNFnAprEuZJucDSMgnUHGePyxgyRqNCWOsG0-K2nTjmKcUug@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

Hi KOSAKi,

On Tue, Jul 12, 2011 at 6:40 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> (2011/07/12 18:27), Minchan Kim wrote:
>> Hi Mel,
>>
>> On Mon, Jul 11, 2011 at 10:01 PM, Mel Gorman <mgorman@suse.de> wrote:
>>> Zone reclaim is similar to direct reclaim in a number of respects.
>>> PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
>>> but it's set also set for zone_reclaim which is inappropriate.
>>> Setting it potentially allows zone_reclaim users to cause large IO
>>> stalls which is worse than remote memory accesses.
>>
>> As I read zone_reclaim_mode in vm.txt, I think it's intentional.
>> It has meaning of throttle the process which are writing large amounts
>> of data. The point is to prevent use of remote node's free memory.
>>
>> And we has still the comment. If you're right, you should remove comment=
.
>> " =C2=A0 =C2=A0 =C2=A0 =C2=A0 * and we also need to be able to write out=
 pages for RECLAIM_WRITE
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and RECLAIM_SWAP."
>>
>>
>> And at least, we should Cc Christoph and KOSAKI.
>
> Of course, I'll take full ack this. Do you remember I posted the same pat=
ch
> about one year ago. At that time, Mel disagreed me and I'm glad to see he=
 changed
> the mind. :)


I remember that but I don't know why Mel didn't ack at that time.
http://lkml.org/lkml/2010/8/5/44

Anyway, Hannes's bd2f6199cf is to introduce lumpy reclaim of
zone_reclaim so it's natural to increase latency for getting big order
pages(ie, it's a trade-off).

And as I read about zone_reclaim_mode in Documentation/sysctl/vm.txt,
I think big latency(ie, throttling of the process) is intentional to
prevent stealing pages for other nodes.

If I am not against this patch, at least, we need agreement of
Christoph and others and if we agree this change, we changes vm.txt,
too.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
