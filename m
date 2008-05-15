Message-Id: <482C2631.1030600@mxp.nes.nec.co.jp>
Date: Thu, 15 May 2008 21:01:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <6599ad830805150019v5ba23fe1xe5a6e8b80bc194f5@mail.gmail.com> <20080515085606.7239D5A07@siro.lan>
In-Reply-To: <20080515085606.7239D5A07@siro.lan>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: menage@google.com, minoura@valinux.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, hugh@veritas.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On 2008/05/15 17:56 +0900, YAMAMOTO Takashi wrote:
>>>  > If so, why is this better
>>>  > than charging for actual swap usage?
>>>
>>>  its behaviour is more determinstic and it uses less memory.
>>>  (than nishimura-san's one, which charges for actual swap usage.)
>>>

Consuming more memory cannot be helped for my controller...

>> Using less memory is good, but maybe not worth it if the result isn't so useful.
>>
>> I'd say that it's less deterministic than nishimura-san's controller -
>> with his you just need to know how much swap is in use (which you can
>> tell by observing the app on a real system) but with yours you also
>> have to know whether there are any processes sharing anon pages (but
>> not mms).
> 
> deterministic in the sense that, even when two or more processes
> from different cgroups are sharing a page, both of them, rather than
> only unlucky one, are always charged.
> 

I'm not sure whether this behavior itself is good or bad,
but I think it's not good idea to make memory controller,
which charges only one process for a shared page,
and swap controller behave differently.
I think it will be confusing for users. At least,
I would feel it strange.

> another related advantage is that it's possible to move charges
> quite precisely when moving a task among cgroups.
> 

Moving charges is one of future todo of my controller.
But, as you say, it won't be so precise as yours.


Thanks,
Daisuke Nishimura.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
