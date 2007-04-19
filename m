Message-ID: <46271FB7.9030408@google.com>
Date: Thu, 19 Apr 2007 00:52:23 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/8] Cpuset aware writeback
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <45C2960B.9070907@google.com> <Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com> <46019F67.3010300@google.com> <Pine.LNX.4.64.0703211428430.4832@schroedinger.engr.sgi.com> <4626CEDA.7050608@google.com> <Pine.LNX.4.64.0704181948260.8743@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704181948260.8743@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 18 Apr 2007, Ethan Solomita wrote:
>
>   
>>    Any new ETA? I'm trying to decide whether to go back to your original
>> patches or wait for the new set. Adding new knobs isn't as important to me as
>> having something that fixes the core problem, so hopefully this isn't waiting
>> on them. They could always be patches on top of your core patches.
>>    -- Ethan
>>     
>
> Hmmmm.... Sorry. I got distracted and I have sent them to Kame-san who was 
> interested in working on them. 
>
> I have placed the most recent version at
> http://ftp.kernel.org/pub/linux/kernel/people/christoph/cpuset_dirty
>   

    Do you expect any conflicts with the per-bdi dirty throttling patches?
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
