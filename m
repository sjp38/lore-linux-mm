Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 64BFA6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:44:06 -0400 (EDT)
Message-ID: <4F833BF5.4040001@nod.at>
Date: Mon, 09 Apr 2012 21:43:49 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: swapoff() runs forever
References: <4F81F564.3020904@nod.at> <4F82752A.6020206@openvz.org> <4F82B6ED.2010500@nod.at> <alpine.LSU.2.00.1204091123380.1430@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204091123380.1430@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>

Am 09.04.2012 20:40, schrieb Hugh Dickins:
> On Mon, 9 Apr 2012, Richard Weinberger wrote:
>> Am 09.04.2012 07:35, schrieb Konstantin Khlebnikov:
>>> Richard Weinberger wrote:
>>>> Hi!
>>>>
>>>> I'm observing a strange issue (at least on UML) on recent Linux kernels.
>>>> If swap is being used the swapoff() system call never terminates.
>>>> To be precise "while ((i = find_next_to_unuse(si, i)) != 0)" in try_to_unuse()
>>>> never terminates.
>>>>
>>>> The affected machine has 256MiB ram and 256MiB swap.
>>>> If an application uses more than 256MiB memory swap is being used.
>>>> But after the application terminates the free command still reports that a few
>>>> MiB are on my swap device and swappoff never terminates.
>>>
>>> After last tmpfs changes swapoff can take minutes.
>>> Or this time it really never terminates?
>>
>> I've never waited forever. ;-)
>
> Your lack of dedication is disappointing.
>
>> Once I've waited for>30 minutes.
>>
>> I don't think that it's related to tmpfs because it happens
>> also while shutting down the system after all filesystems have been unmounted.
>
> Like you I'd assume that it is really was going to be forever,
> rather than swapoff just being characteristically slow:
> a few MiB left on swap shouldn't take long to get off.
>
> I've not seen any such issue in recent months (or years), but
> I've not been using UML either.  The most likely cause that springs
> to mind would be corruption of the vmalloc'ed swap map: that would
> be very likely to cause such a hang.

Okay, I'll dig into this.

> You say "recent Linux kernels": I wonder what "recent" means.
> Is this something you can reproduce quickly and reliably enough
> to do a bisection upon?
>

It happens quite reliably on 3.2 and 3.3.
On 3.1 and 3.0 sometimes.
I've already wasted half a day with bisecting it.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
