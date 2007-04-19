Message-ID: <4626CEDA.7050608@google.com>
Date: Wed, 18 Apr 2007 19:07:22 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/8] Cpuset aware writeback
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <45C2960B.9070907@google.com> <Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com> <46019F67.3010300@google.com> <Pine.LNX.4.64.0703211428430.4832@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703211428430.4832@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 21 Mar 2007, Ethan Solomita wrote:
>
>   
>> Christoph Lameter wrote:
>>     
>>> On Thu, 1 Feb 2007, Ethan Solomita wrote:
>>>
>>>       
>>>>    Hi Christoph -- has anything come of resolving the NFS / OOM concerns
>>>> that
>>>> Andrew Morton expressed concerning the patch? I'd be happy to see some
>>>> progress on getting this patch (i.e. the one you posted on 1/23) through.
>>>>         
>>> Peter Zilkstra addressed the NFS issue. I will submit the patch again as
>>> soon as the writeback code stabilizes a bit.
>>>       
>> 	I'm pinging to see if this has gotten anywhere. Are you ready to
>> resubmit? Do we have the evidence to convince Andrew that the NFS issues are
>> resolved and so this patch won't obscure anything?
>>     
>
> The NFS patch went into Linus tree a couple of days ago and I have a new 
> version ready with additional support to set per dirty ratios per cpu. 
> There is some interest in adding more VM controls to this patch. I hope I 
> can post the next rev by tomorrow.
>   

    Any new ETA? I'm trying to decide whether to go back to your 
original patches or wait for the new set. Adding new knobs isn't as 
important to me as having something that fixes the core problem, so 
hopefully this isn't waiting on them. They could always be patches on 
top of your core patches.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
