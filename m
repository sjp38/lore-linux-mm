Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 6934A6B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 00:11:43 -0500 (EST)
Received: by bkty12 with SMTP id y12so7895196bkt.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 21:11:41 -0800 (PST)
Message-ID: <4F447904.90500@openvz.org>
Date: Wed, 22 Feb 2012 09:11:32 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/22] mm: lru_lock splitting
References: <20120220171138.22196.65847.stgit@zurg> <m2boor33g8.fsf@firstfloor.org>
In-Reply-To: <m2boor33g8.fsf@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Andi Kleen wrote:
> Konstantin Khlebnikov<khlebnikov@openvz.org>  writes:
>
> Konstantin,
>
>> There complete patch-set with my lru_lock splitting
>> plus all related preparations and cleanups rebased to next-20120210
>
> On large systems we're also seeing lock contention on the lru_lock
> without using memcgs. Any thoughts how this could be extended for this
> situation too?

We can split lru_lock by pfn-based interleaving.
After all these cleanups it is very easy. I already have patch for this.

>
> Thanks,
>
> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
