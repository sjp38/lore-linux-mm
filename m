From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 18 Jan 2007 17:53:04 +1100 (EST)
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <Pine.LNX.4.64.0701161050330.30540@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701181745480.12779@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.64.0701161050330.30540@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Davies <pauld@gelato.unsw.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Christoph Lameter wrote:

> On Sat, 13 Jan 2007, Paul Davies wrote:
>
>> INSTRUCTIONS,BENCHMARKS and further information at the site below:
>
> The benchmarks seem to be a mixed bag. Mostly up to the same speed, some
> minor improvements in some operations some minor regressions in others. If
> we cannot find any major regressions on other platforms then I would
> think that the patchset is acceptable on that ground.
I will expand the PTI testing to other archictectures after LCA.  The
results will be placed on our wiki and I will notify linux-mm when I have
gathered some more interesting results.

Cheers

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
