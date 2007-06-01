Message-ID: <46608E76.9080109@goop.org>
Date: Fri, 01 Jun 2007 14:24:06 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org> <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com> <46606C71.9010008@goop.org> <Pine.LNX.4.64.0706011357290.4664@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706011357290.4664@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>> I disagree.  There are plenty of boundary conditions where 0 is not
>> really a special case, and making it a special case just complicates
>> things.  I think at least some of the patches posted to silence this
>> warning have been generally negative for code quality.  If we were
>> seeing lots of zero-sized allocations then that might indicate something
>> is amiss, but it seems to me that there's just a scattered handful.
>>
>> I agree that it's always a useful debugging aid to make sure that
>> allocated regions are not over-run, but 0-sized allocations are not
>> special in this regard.
>>     
>
> Still insisting on it even after the discovery of the cpuset kmalloc(0) issue?
>   

Sure. That was a normal buffer-overrun bug. There's nothing special
about 0-sized allocations.

J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
