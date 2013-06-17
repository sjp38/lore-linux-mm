Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AB9976B0033
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 21:56:00 -0400 (EDT)
Message-ID: <51BE6BFC.3030009@cn.fujitsu.com>
Date: Mon, 17 Jun 2013 09:53:00 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Add unlikely for current_order test
References: <51BC4A83.50302@gmail.com> <alpine.DEB.2.02.1306161103020.22688@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306161103020.22688@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi David,

On 06/17/2013 02:04 AM, David Rientjes wrote:
> On Sat, 15 Jun 2013, Zhang Yanfei wrote:
> 
>> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>
>> Since we have an unlikely for the "current_order >= pageblock_order / 2"
>> test above, adding an unlikely for this "current_order >= pageblock_order"
>> test seems more appropriate.
>>
> 
> I don't understand the justification at all, current_order being unlikely 
> greater than or equal to pageblock_order / 2 doesn't imply at all that 
> it's unlikely that current_order is greater than or equal to 
> pageblock_order.
> 

hmmm... I am confused. Since current_order is >= pageblock_order / 2 is unlikely,
why current_order is >= pageblock_order isn't unlikely. Or there are other
tips?

Actually, I am also a little confused about why current_order should be
unlikely greater than or equal to pageblock_order / 2. When borrowing pages
with other migrate_type, we always search from MAX_ORDER-1, which is greater
or equal to pageblock_order.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
