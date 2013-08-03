Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B8CEC6B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 17:22:08 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id bq6so305563qab.4
        for <linux-mm@kvack.org>; Sat, 03 Aug 2013 14:22:07 -0700 (PDT)
Message-ID: <51FD7483.5060504@gmail.com>
Date: Sat, 03 Aug 2013 17:22:11 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Possible deadloop in direct reclaim?
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com> <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com> <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com> <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com> <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com> <51F69BD7.2060407@gmail.com> <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com> <51F9CBC0.2020006@gmail.com> <51F9E265.7030503@oracle.com>
In-Reply-To: <51F9E265.7030503@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Lisa Du <cldu@marvell.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>

(8/1/13 12:21 AM), Bob Liu wrote:
> Hi KOSAKI,
>
> On 08/01/2013 10:45 AM, KOSAKI Motohiro wrote:
>
>>
>> Please read more older code. Your pointed code is temporary change and I
>> changed back for fixing
>> bugs.
>> If you look at the status in middle direct reclaim, we can't avoid race
>> condition from multi direct
>> reclaim issues. Moreover, if kswapd doesn't awaken, it is a problem.
>> This is a reason why current code
>> behave as you described.
>> I agree we should fix your issue as far as possible. But I can't agree
>> your analysis.
>>
>
> I found this thread:
> mm, vmscan: fix do_try_to_free_pages() livelock
> https://lkml.org/lkml/2012/6/14/74
>
> I think that's the same issue Lisa met.
>
> But I didn't find out why your patch didn't get merged?
> There were already many acks.

Just because I misunderstood the patch has already been merged. OK, I'll
resend this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
