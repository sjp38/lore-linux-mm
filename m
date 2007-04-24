Message-ID: <462E7AB6.8000502@shadowen.org>
Date: Tue, 24 Apr 2007 22:46:30 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>	<Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>	<20070424132740.e4bdf391.akpm@linux-foundation.org>	<Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>	<20070424134325.f71460af.akpm@linux-foundation.org>	<Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>	<20070424141826.952d2d32.akpm@linux-foundation.org>	<Pine.LNX.4.64.0704241429240.13904@schroedinger.engr.sgi.com> <20070424143635.cdff71de.akpm@linux-foundation.org>
In-Reply-To: <20070424143635.cdff71de.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 24 Apr 2007 14:30:16 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
>> On Tue, 24 Apr 2007, Andrew Morton wrote:
>>
>>>> Could we get a .config?
>>> test.kernel.org configs are subtly hidden on the front page.  Go to
>>> test.kernel.org, click on the "amd64" or "numaq" links in the title row
>>> there.
>>>
>>> The offending machine is elm3b6.
>> My x86_64 box boots fine with the indicated .config.
> 
> So do both of mine.
> 
>> Hardware related?
> 
> Well it's AMD64, presumably real NUMA.  Maybe try numa=fake=4?

Yep real NUMA box.  Will try and get hold of the box to test.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
