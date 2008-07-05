Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: Jaswinder Singh <jaswinder@infradead.org>
Content-Type: text/plain
Date: Sat, 05 Jul 2008 11:19:18 +0530
Message-Id: <1215236958.4136.6.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>, dwmw2@infradead.org, jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Respected Sirs,

On Sat, Jul 5, 2008 at 2:07 AM, David Miller <davem@davemloft.net>
wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Fri, 04 Jul 2008 14:27:15 +0100
>
>> Your argument makes about as much sense as an argument that we should
>> link b43.ko with mac80211.ko so that the 802.11 core code "rides
along
>> in the module's .ko file". It's just silly.
>
> I totally disagree with you.  Jeff is right and you are wrong.
>

Please let me know, if you found the BUG in the tg3 firmare patch :-
http://git.infradead.org/users/dwmw2/firmware-2.6.git?a=commitdiff;h=be4e9388e35b22d6f8aa104baf39f8339825424e

I will try to fix it.

Thank you,

Jaswinder Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
