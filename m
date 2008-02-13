Date: Wed, 13 Feb 2008 15:37:13 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/8][for -mm] mem_notify v6: memory_pressure_notify() caller
In-Reply-To: <20080212145651.69cc34a5.akpm@linux-foundation.org>
References: <2f11576a0802090724s679258c4g7414e0a6983f4706@mail.gmail.com> <20080212145651.69cc34a5.akpm@linux-foundation.org>
Message-Id: <20080213152204.D894.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Hi Andrew

> > and, It is judged out of trouble at the fllowing situations.
> >  o memory pressure decrease and stop moves an anonymous page to the
> > inactive list.
> >  o free pages increase than (pages_high+lowmem_reserve)*2.
> 
> This seems rather arbitrary.  Why choose this stage in the page
> reclaimation process rather than some other stage?
> 
> If this feature is useful then I'd expect that some applications would want
> notification at different times, or at different levels of VM distress.  So
> this semi-randomly-chosen notification point just won't be strong enough in
> real-world use.

Hmmm
actually, This portion become code broat through some bug reports.

Yes, I think it again and implement it more simplefy.
Thanks!


> Does this change work correctly and appropriately for processes which are
> running in a cgroup memory controller?

nice point out.

to be honest, I don't think at mem-cgroup until now.
I will implement it at next post.

> Given the amount of code which these patches add, and the subsequent
> maintenance burden, and the unlikelihood of getting many applications to
> actually _use_ the interface, it is not obvious to me that inclusion in the
> kernel is justifiable, sorry.

OK.
I'll implement it again more simplefy.
Thanks.


> memory_pressure_notify() is far too large to be inlined.

OK.
I will fix it.

> Some of the patches were wordwrapped.

Agghh..
I will don't use gmail at next post.
sorry.


and,
I hope merge only poll_wait_exclusive() and wake_up_locked_nr()
if you don't mind.

this 2 portion anybody noclaim about 2 month.
and I think it is useful function by many people.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
