Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 246186B0144
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:58:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6791569dak.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 07:58:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206110937430.31180@router.home>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com>
 <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com>
 <alpine.DEB.2.00.1206110937430.31180@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 10:58:27 -0400
Message-ID: <CAHGf_=rdcoC8wWzcAfDpqekFnmBSCtyEp2nFXV+DFBzgpHEF1A@mail.gmail.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 11, 2012 at 10:40 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:
>
>> On 6/11/2012 10:02 AM, Christoph Lameter wrote:
>> > On Mon, 11 Jun 2012, kosaki.motohiro@gmail.com wrote:
>> >
>> >> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >>
>> >> commit 2244b95a7b (zoned vm counters: basic ZVC (zoned vm counter)
>> >> implementation) broke protection column. It is a part of "pages"
>> >> attribute. but not it is showed after vmstats column.
>> >>
>> >> This patch restores the right position.
>> >
>> > Well this reorders the output. vmstats are also counts of pages. I am not
>> > sure what the difference is.
>>
>> No. In this case, "pages" mean zone attribute. In the other hand, vmevent
>> is a statistics.
>
> The vmevent countes are something different from the zone counters. Event
> counters are indeed statistics only but the numbers here were intended
> to be are actual counts of pages. Well some of them like the numa_XXX are
> stats you are right. Those could be moved off the ZVCs and become event
> counters.
>
>> > You are not worried about breaking something that may scan the zoneinfo
>> > output with this change? Its been this way for 6 years and its likely that
>> > tools expect the current layout.
>>
>> I don't worry about this. Because of, /proc/zoneinfo is cray machine unfrinedly
>> format and afaik no application uses it.
>
> Cray? What does that have to do with it.

sorry. s/cray/crazy/


>
>> btw, I believe we should aim /sys/devices/system/node/<node-num>/zones new directory
>> and export zone infos as machine readable format.
>
> Yes that would be a good thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
