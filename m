Message-ID: <457DA9F9.9040106@cern.ch>
Date: Mon, 11 Dec 2006 19:56:57 +0100
From: Ramiro Voicu <Ramiro.Voicu@cern.ch>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
References: <200612070355.kB73tGf4021820@fire-2.osdl.org> <20061206201246.be7fb860.akpm@osdl.org> <4577A36B.6090803@cern.ch> <20061206230338.b0bf2b9e.akpm@osdl.org> <45782B32.6040401@cern.ch> <Pine.LNX.4.64.0612072101120.27573@blonde.wat.veritas.com> <20061208155200.0e2794a1.akpm@osdl.org> <Pine.LNX.4.64.0612090427180.3684@blonde.wat.veritas.com> <457AF156.8070606@cern.ch> <Pine.LNX.4.64.0612091829550.22335@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0612091829550.22335@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

 I've tested the patch on the other machine also and it works as
expected, so the bug ca be closed now.

 Thank you very much for your support!

Regards,
Ramiro

Hugh Dickins wrote:
> On Sat, 9 Dec 2006, Ramiro Voicu wrote:
>> Hugh Dickins wrote:
>>> On Fri, 8 Dec 2006, Andrew Morton wrote:
>>>> On Thu, 7 Dec 2006 21:22:57 +0000 (GMT)
>>>> Ramiro, have you had a chance to test this yet?
>>> Here's a bigger but better patch: if you wouldn't mind,
>>> please try this one instead, Ramiro - thanks.
>> It seems that this patch fixed the problem. I tested on my desktop and
>> the problem seems gone.
> 
> Great, thanks.  Well, actually it's trivial that it has fixed
> the problem, in that it removed that particular BUG_ON: what's more
> important is that it then allowed your program to work as usual, good.
> 
>> Based on what Hugh supposed, I was able to have a small java program to
>> test it ... and indeed it is very possible that there was a race in the
>> initial app
>>
>> I will try to test it tomorrow on the other machine ( it is unable to
>> boot now after a hard reboot ), but I think the bug can be closed now.
>>
>> Thank you very much for your support!
> 
> Thank _you_ very much for reporting and testing:
> it's a pleasure to deal with bugs we can fix so easily!
> 
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
