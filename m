Message-ID: <4820A431.3000600@firstfloor.org>
Date: Tue, 06 May 2008 20:32:17 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/cgroup.c add error check
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <87wsm7bo1n.fsf@basil.nowhere.org> <2f11576a0805060602gf4cf0f9t85391939146efccf@mail.gmail.com>
In-Reply-To: <2f11576a0805060602gf4cf0f9t85391939146efccf@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>  > on heavy workload, call_usermodehelper() may failure
>>  > because it use kzmalloc(GFP_ATOMIC).
>>
>>  Better just fix it to not use GFP_ATOMIC in the first place.
> 
> Ah, makes sense.
> I'll try toi create that patch.

Thanks.

> 
> but if GFP_KERNEL is used, We still need error check, IMHO.

Yes, but no retry (or if you're sure you cannot fail use __GFP_NOFAIL
too, but that is nasty because it has some risk of deadlock under severe
oom conditions)

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
