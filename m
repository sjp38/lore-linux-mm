Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: Jaswinder Singh <jaswinder@infradead.org>
Content-Type: text/plain
Date: Sat, 05 Jul 2008 12:07:58 +0530
Message-Id: <1215239879.4136.12.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>, David Woodhouse <dwmw2@infradead.org>, Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Respected Jeff,

On Sat, Jul 5, 2008 at 11:44 AM, Jeff Garzik <jeff@garzik.org> wrote:
> David Woodhouse wrote:
>>
>> I'm working on making the required firmware get installed as part of
>> 'make modules_install'.
>
> Great!  That will definitely reduce silent regressions due to build process
> changes.

If other issues are solved, please look at the code of TG3 firmware Patch :-

http://git.infradead.org/users/dwmw2/firmware-2.6.git?a=commitdiff;h=be4e9388e35b22d6f8aa104baf39f8339825424e

And give us your valuable feedback regarding code :)

Can I move to another net drivers ?

Thank you,

Jaswinder Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
