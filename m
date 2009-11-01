Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE59F6B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 09:45:19 -0500 (EST)
Message-ID: <4AED9EB4.5080601@redhat.com>
Date: Sun, 01 Nov 2009 09:44:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use ALLOC_HARDER
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz> <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz> <alpine.DEB.2.00.0910311413160.25524@chino.kir.corp.google.com> <20091031222905.GA32720@elf.ucw.cz> <4AECC04B.9060808@redhat.com> <20091101073527.GB32720@elf.ucw.cz>
In-Reply-To: <20091101073527.GB32720@elf.ucw.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/01/2009 02:35 AM, Pavel Machek wrote:
>>> I believe it would be better to simply remove it.
>>
>> You are against trying to give the realtime tasks a best effort
>> advantage at memory allocation?
>
> Yes. Those memory reserves were for kernel, GPF_ATOMIC and stuff. Now
> realtime tasks are allowed to eat into them. That feels wrong.
>
> "realtime" tasks are not automatically "more important".
>
>> Realtime apps often *have* to allocate memory on the kernel side,
>> because they use network system calls, etc...
>
> So what? As soon as they do that, they lose any guarantees, anyway.

They might lose the absolute guarantee, but that's no reason
not to give it our best effort!

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
