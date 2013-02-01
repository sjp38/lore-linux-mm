Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7CAB86B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 11:57:52 -0500 (EST)
Message-ID: <510BF3F1.2050605@zytor.com>
Date: Fri, 01 Feb 2013 08:57:21 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: PAE problems was [RFC] Reproducible OOM with just a few sleeps
References: <201302010313.r113DTj3027195@como.maths.usyd.edu.au> <510B46C3.5040505@turmel.org> <20130201102044.GA2801@amd.pavel.ucw.cz> <20130201102545.GA3053@amd.pavel.ucw.cz>
In-Reply-To: <20130201102545.GA3053@amd.pavel.ucw.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@denx.de>
Cc: Phil Turmel <philip@turmel.org>, paul.szabo@sydney.edu.au, ben@decadent.org.uk, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/01/2013 02:25 AM, Pavel Machek wrote:
>
> On Fri 2013-02-01 11:20:44, Pavel Machek wrote:
>> On Thu 2013-01-31 23:38:27, Phil Turmel wrote:
>>> On 01/31/2013 10:13 PM, paul.szabo@sydney.edu.au wrote:
>>>> [trim /] Does not that prove that PAE is broken?
>>>
>>> Please, Paul, take *yes* for an answer.  It is broken.  You've received
>>> multiple dissertations on why it is going to stay that way.  Unless you
>>> fix it yourself, and everyone seems to be politely wishing you the best
>>> of luck with that.
>>
>> It is not Paul's job to fix PAE. It is job of whoever broke it to do
>> so.
>>
>> If it is broken with 2GB of RAM, it is clearly not the known "lowmem
>> starvation" issue, it is something else... and probably worth
>> debugging.
>>
>> So, Paul, if you have time and interest... Try to find some old kernel
>> version where sleep test works with PAE. Hopefully there is one. Then
>> do bisection... author of the patch should then fix it. (And if not,
>> at least you have patch you can revert.)
>>
>> rjw is worth cc-ing at that point.
>
> Ouch, and... IIRC (hpa should know for sure), PAE is neccessary for
> R^X support on x86, thus getting more common, not less. If it does not
> work, that's bad news.
>
> Actually, if PAE is known broken, it should probably get marked as
> such in Kconfig. That's sure to get some discussion started...
> 									Pavel
>

OK, so by the time this thread gets to me there is of course no 
information in it.

The vast majority of all 32-bit kernels compiled these days are PAE, so 
it would seem rather odd if PAE was totally broken.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
