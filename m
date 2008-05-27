Message-Id: <483BC690.6010206@mxp.nes.nec.co.jp>
Date: Tue, 27 May 2008 17:30:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <483647AB.8090104@mxp.nes.nec.co.jp> <20080527073118.0D92B5A0E@siro.lan> <483BBB4C.3040501@linux.vnet.ibm.com>
In-Reply-To: <483BBB4C.3040501@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, m-ikeda@ds.jp.nec.com
List-ID: <linux-mm.kvack.org>

On 2008/05/27 16:42 +0900, Balbir Singh wrote:
> YAMAMOTO Takashi wrote:
>> hi,
>>
>>>> Thanks for looking into this. Yamamoto-San is also looking into a swap
>>>> controller. Is there a consensus on the approach?
>>>>
>>> Not yet, but I think we should have some consensus each other
>>> before going further.
>>>
>>>
>>> Thanks,
>>> Daisuke Nishimura.
>> while nishimura-san's one still seems to have a lot of todo,
>> it seems good enough as a start point to me.
>> so i'd like to withdraw mine.
>>
>> nishimura-san, is it ok for you?
>>
Of cource.
I'll work hard to make it better.

> 
> I would suggest that me merge the good parts from both into the swap controller.
> Having said that I'll let the two of you decide on what the good aspects of both
> are. I cannot see any immediate overlap, but there might be some w.r.t.
> infrastructure used.
> 
Well, you mean you'll make another patch based on yamamoto-san's
and mine?

Basically, I think it's difficult to merge
because we charge different objects.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
