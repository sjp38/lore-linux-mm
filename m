Subject: Re: [PATCH 4/8][for -mm] mem_notify v6: memory_pressure_notify() caller
From: Andi Kleen <andi@firstfloor.org>
References: <2f11576a0802090724s679258c4g7414e0a6983f4706@mail.gmail.com>
	<20080212145651.69cc34a5.akpm@linux-foundation.org>
	<20080213152204.D894.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Wed, 13 Feb 2008 16:03:58 +0100
In-Reply-To: <20080213152204.D894.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI Motohiro's message of "Wed\, 13 Feb 2008 15\:37\:13 +0900")
Message-ID: <p73y79o290h.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:
>
> to be honest, I don't think at mem-cgroup until now.

There is not only mem-cgroup BTW, but also NUMA node restrictons from
NUMA memory policy. So this means a process might not be able to access
all memory.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
