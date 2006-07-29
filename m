Received: by nf-out-0910.google.com with SMTP id x30so145327nfb
        for <linux-mm@kvack.org>; Sat, 29 Jul 2006 16:57:57 -0700 (PDT)
Message-ID: <44CBF60C.3090508@gmail.com>
Date: Sun, 30 Jul 2006 01:57:41 +0159
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: swsusp regression (s2dsk) [Was: 2.6.18-rc2-mm1]
References: <20060727015639.9c89db57.akpm@osdl.org> <44CBA1AD.4060602@gmail.com> <200607292059.59106.rjw@sisk.pl> <44CBE9D5.9030707@gmail.com> <20060729232216.GB1983@elf.ucw.cz>
In-Reply-To: <20060729232216.GB1983@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jiri Slaby <jirislaby@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-pm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pavel Machek napsal(a):
> Hi!
> 
>>>> I have problems with swsusp again. While suspending, the very last thing kernel
>>>> writes is 'restoring higmem' and then hangs, hardly. No sysrq response at all.
>>>> Here is a snapshot of the screen:
>>>> http://www.fi.muni.cz/~xslaby/sklad/swsusp_higmem.gif
>>>>
>>>> It's SMP system (HT), higmem enabled (1 gig of ram).
>>> Most probably it hangs in device_power_up(), so the problem seems to be
>>> with one of the devices that are resumed with IRQs off.
>>>
>>> Does vanila .18-rc2 work?
>> Yup, it does.
> 
> Can you try up kernel, no highmem? (mem=512M)?

It writes then:
p16v: status 0xffffffff, mask 0x00001000, pvoice f7c04a20, use 0
in endless loop when resuming -- after reading from swap.

regards,
-- 
<a href="http://www.fi.muni.cz/~xslaby/">Jiri Slaby</a>
faculty of informatics, masaryk university, brno, cz
e-mail: jirislaby gmail com, gpg pubkey fingerprint:
B674 9967 0407 CE62 ACC8  22A0 32CC 55C3 39D4 7A7E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
