Message-ID: <462EA46E.8000307@shadowen.org>
Date: Wed, 25 Apr 2007 01:44:30 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>	 <20070424132740.e4bdf391.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>	 <20070424134325.f71460af.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>	 <20070424141826.952d2d32.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0704241429240.13904@schroedinger.engr.sgi.com>	 <20070424143635.cdff71de.akpm@linux-foundation.org>	 <462E7AB6.8000502@shadowen.org>  <462E9DDC.40700@shadowen.org> <1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
In-Reply-To: <1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
> On Wed, 2007-04-25 at 01:16 +0100, Andy Whitcroft wrote:
>> Andy Whitcroft wrote:
>>> Andrew Morton wrote:
>>>> On Tue, 24 Apr 2007 14:30:16 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
>>>>
>>>>> On Tue, 24 Apr 2007, Andrew Morton wrote:
>>>>>
>>>>>>> Could we get a .config?
>>>>>> test.kernel.org configs are subtly hidden on the front page.  Go to
>>>>>> test.kernel.org, click on the "amd64" or "numaq" links in the title row
>>>>>> there.
>>>>>>
>>>>>> The offending machine is elm3b6.
>>>>> My x86_64 box boots fine with the indicated .config.
>>>> So do both of mine.
>>>>
>>>>> Hardware related?
>>>> Well it's AMD64, presumably real NUMA.  Maybe try numa=fake=4?
>>> Yep real NUMA box.  Will try and get hold of the box to test.
>>>
>>> -apw
>> git bisect points to:
>>
>>     quicklist-support-for-x86_64
>>
>> Reverting just this patch sorts this problem on the x86_64.
> 
> Hmm.. I narrowed it further down to ..
> 
> quicklists-for-page-table-pages-avoid-useless-virt_to_page-
> conversion.patch
> 
> Andy, can you try backing out only this and enable QUICK_LIST
> on your machine ?

Yep confirmed that reverting that one is enough to fix this machine.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
