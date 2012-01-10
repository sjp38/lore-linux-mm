Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AD5D06B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 21:08:45 -0500 (EST)
Message-ID: <4F0B9DA4.5010509@tao.ma>
Date: Tue, 10 Jan 2012 10:08:36 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not drain pagevecs for mlock
References: <1325226961-4271-1-git-send-email-tm@tao.ma> <CAHGf_=qOGy3MQgiFyfeG82+gbDXTBT5KQjgR7JqMfQ7e7RSGpA@mail.gmail.com> <4EFD7AE3.8020403@tao.ma> <CAHGf_=pODc6fLGJAEZWzQtUd6fj6v=fV9n6UTwysqRR1SwY++A@mail.gmail.com> <4EFD8832.6010905@tao.ma> <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <4F069120.8060300@tao.ma> <CAHGf_=qhKbVCeUe+y8Hmb=ke-f417K5EYFo=j4ZODVGwewgh6A@mail.gmail.com> <4F06951E.7050605@tao.ma> <4F06959D.2070100@gmail.com> <4F0698D8.3000300@tao.ma> <4F0B7F1E.40504@gmail.com>
In-Reply-To: <4F0B7F1E.40504@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 01/10/2012 07:58 AM, KOSAKI Motohiro wrote:
> (1/6/12 1:46 AM), Tao Ma wrote:
>> On 01/06/2012 02:33 PM, KOSAKI Motohiro wrote:
>>> (1/6/12 1:30 AM), Tao Ma wrote:
>>>> On 01/06/2012 02:18 PM, KOSAKI Motohiro wrote:
>>>>> 2012/1/6 Tao Ma<tm@tao.ma>:
>>>>>> Hi Kosaki,
>>>>>> On 12/30/2011 06:07 PM, KOSAKI Motohiro wrote:
>>>>>>>>> Because your test program is too artificial. 20sec/100000times =
>>>>>>>>> 200usec. And your
>>>>>>>>> program repeat mlock and munlock the exact same address. so,
>>>>>>>>> yes, if
>>>>>>>>> lru_add_drain_all() is removed, it become near no-op. but it's
>>>>>>>>> worthless comparision.
>>>>>>>>> none of any practical program does such strange mlock usage.
>>>>>>>> yes, I should say it is artificial. But mlock did cause the
>>>>>>>> problem in
>>>>>>>> our product system and perf shows that the mlock uses the system
>>>>>>>> time
>>>>>>>> much more than others. That's the reason we created this program
>>>>>>>> to test
>>>>>>>> whether mlock really sucks. And we compared the result with
>>>>>>>> rhel5(2.6.18) which runs much much faster.
>>>>>>>>
>>>>>>>> And from the commit log you described, we can remove
>>>>>>>> lru_add_drain_all
>>>>>>>> safely here, so why add it? At least removing it makes mlock much
>>>>>>>> faster
>>>>>>>> compared to the vanilla kernel.
>>>>>>>
>>>>>>> If we remove it, we lose to a test way of mlock. "Memlocked"
>>>>>>> field of
>>>>>>> /proc/meminfo
>>>>>>> show inaccurate number very easily. So, if 200usec is no avoidable,
>>>>>>> I'll ack you.
>>>>>>> But I'm not convinced yet.
>>>>>> Do you find something new for this?
>>>>>
>>>>> No.
>>>>>
>>>>> Or more exactly, 200usec is my calculation mistake. your program call
>>>>> mlock
>>>>> 3 times per each iteration. so, correct cost is 66usec.
>>>> yes, so mlock can do 15000/s, it is even slower than the whole i/o time
>>>> for some not very fast ssd disk and I don't think it is endurable. I
>>>> guess we should remove it, right? Or you have another other suggestion
>>>> that I can try for it?
>>>
>>> read whole thread.
>> I have read the whole thread, and you just described that the test case
>> is artificial and there is no suggestion or patch about how to resolve
>> it. As I have said that it is very time-consuming and with more cpu
>> cores, the more penalty, and an i/o time for a ssd can be faster than
>> it. So do you think 66 usec is OK for a memory operation?
> 
> I don't think you've read the thread at all. please read akpm's commnet.
> 
> http://www.spinics.net/lists/linux-mm/msg28290.html
Oh, your patch set doesn't cc to me, so my mail filter moved it to
another directory..
Sorry and I will read the whole thread. Thanks again for your time.

Thanks
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
