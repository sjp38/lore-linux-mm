Received: by rv-out-0708.google.com with SMTP id f25so11216947rvb.26
        for <linux-mm@kvack.org>; Tue, 24 Jun 2008 23:58:26 -0700 (PDT)
Message-ID: <28c262360806242358q348e18a4vb9c48b4b853b0384@mail.gmail.com>
Date: Wed, 25 Jun 2008 15:58:26 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080624092824.4f0440ca@bree.surriel.com>
	 <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
	 <20080625150141.D845.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25, 2008 at 3:56 PM, MinChan Kim <minchan.kim@gmail.com> wrote:
> On Wed, Jun 25, 2008 at 3:08 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi Kim-san,
>>
>>> >> So, if priority==0, We should try to reclaim all page for prevent OOM.
>>> >
>>> > You are absolutely right.  Good catch.
>>>
>>> I have a concern about application latency.
>>> If lru list have many pages, it take a very long time to scan pages.
>>> More system have many ram, More many time to scan pages.
>>
>> No problem.
>>
>> priority==0 indicate emergency.
>> it doesn't happend on typical workload.
>>
>
> I see :)
>
> But if such emergency happen in embedded system, application can't be
> executed for some time.
> I am not sure how long time it take.
> But In some application, schedule period is very important than memory
> reclaim latency.
>
> Now, In your patch, when such emergency happen, it continue to reclaim
> page until it will scan entire page of lru list.
> It

with my mistake, I omit following message. :(

So, we need cut-off mechanism to reduce application latency.
So In my opinion, If we modify some code of Takenori's patch, we can
apply his idea to prevent latency probelm.

>>> Of course I know this is trade-off between memory efficiency VS latency.
>>> But In embedded, some application think latency is more important
>>> thing than memory efficiency.
>>> We need some mechanism to cut off scanning time.
>>>
>>> I think Takenori Nagano's "memory reclaim more efficiently patch" is
>>> proper to reduce application latency in this case If we modify some
>>> code.
>>
>> I think this is off-topic.
>>
>> but Yes.
>> both my page reclaim throttle and nagano-san's patch provide
>> reclaim cut off mechanism.
>>
>>
>> and more off-topic,
>> nagano-san's patch improve only priority==12.
>> So, typical embedded doesn't improve so big because
>> embedded system does't have so large memory.
>>
>>
>>
>>
>
>
>
> --
> Kinds regards,
> MinChan Kim
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
