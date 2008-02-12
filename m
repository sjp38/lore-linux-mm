Date: Tue, 12 Feb 2008 14:56:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/8][for -mm] mem_notify v6: memory_pressure_notify()
 caller
Message-Id: <20080212145651.69cc34a5.akpm@linux-foundation.org>
In-Reply-To: <2f11576a0802090724s679258c4g7414e0a6983f4706@mail.gmail.com>
References: <2f11576a0802090724s679258c4g7414e0a6983f4706@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Feb 2008 00:24:28 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:

> the notification point to happen whenever the VM moves an
> anonymous page to the inactive list - this is a pretty good indication
> that there are unused anonymous pages present which will be very likely
> swapped out soon.
> 
> and, It is judged out of trouble at the fllowing situations.
>  o memory pressure decrease and stop moves an anonymous page to the
> inactive list.
>  o free pages increase than (pages_high+lowmem_reserve)*2.

This seems rather arbitrary.  Why choose this stage in the page
reclaimation process rather than some other stage?

If this feature is useful then I'd expect that some applications would want
notification at different times, or at different levels of VM distress.  So
this semi-randomly-chosen notification point just won't be strong enough in
real-world use.

Does this change work correctly and appropriately for processes which are
running in a cgroup memory controller?

Given the amount of code which these patches add, and the subsequent
maintenance burden, and the unlikelihood of getting many applications to
actually _use_ the interface, it is not obvious to me that inclusion in the
kernel is justifiable, sorry.


memory_pressure_notify() is far too large to be inlined.

Some of the patches were wordwrapped.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
