Received: by wa-out-1112.google.com with SMTP id j37so1448426waf.22
        for <linux-mm@kvack.org>; Tue, 25 Nov 2008 06:30:32 -0800 (PST)
Message-ID: <2f11576a0811250630i1d668factccde119def9ff341@mail.gmail.com>
Date: Tue, 25 Nov 2008 23:30:32 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <492BFE6F.5090902@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081124145057.4211bd46@bree.surriel.com>
	 <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <492BFE6F.5090902@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

2008/11/25 Rik van Riel <riel@redhat.com>:
> KOSAKI Motohiro wrote:
>>>
>>> Sometimes the VM spends the first few priority rounds rotating back
>>> referenced pages and submitting IO.  Once we get to a lower priority,
>>> sometimes the VM ends up freeing way too many pages.
>>>
>>> The fix is relatively simple: in shrink_zone() we can check how many
>>> pages we have already freed, direct reclaim tasks break out of the
>>> scanning loop if they have already freed enough pages and have reached
>>> a lower priority level.
>>>
>>> However, in order to do this we do need to know how many pages we already
>>> freed, so move nr_reclaimed into scan_control.
>>>
>>> Signed-off-by: Rik van Riel <riel@redhat.com>
>>> ---
>>> Kosaki, this should address the zone scanning pressure issue.
>>
>> hmmmm. I still don't like the behavior when priority==DEF_PRIORITY.
>> but I also should explain by code and benchmark.
>
> Well, the behaviour when priority==DEF_PRIORITY is the
> same as the kernel's behaviour without the patch...


Yes, but I think it decrease this patch's valueable...



>> therefore, I'll try to mesure this patch in this week.
>
> Looking forward to it.

thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
