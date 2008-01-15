Message-ID: <478CF609.3090304@qumranet.com>
Date: Tue, 15 Jan 2008 20:06:01 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com> <47891A5C.8060907@qumranet.com> <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com> <478C62F8.2070702@qumranet.com> <Pine.LNX.4.64.0801150938260.9893@schroedinger.engr.sgi.com> <478CF30F.1010100@qumranet.com> <Pine.LNX.4.64.0801150956040.10089@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801150956040.10089@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 15 Jan 2008, Avi Kivity wrote:
>
>   
>>> Ahh.. Okay I was talking about a guest exporting its memory to another
>>> guest.
>>>   
>>>       
>> That's not very different, if they are on the same host?
>>     
>
> But each guest has its own page structs. They cannot share page structs. 
> Concurrent access of two independent kernel instances for synchronization 
> and status maintenance to a single page struct?
>   

There's a host page struct (that the guest know nothing about and cannot 
touch), and optionally a guest page struct for each guest (that the host 
and the other guest know nothing about).

The guest page struct is optional, since it is up to the guest to create 
it.  kvm doesn't care.  If the guest isn't Linux, there certainly won't 
be a page struct.

The host page struct may disappear if the host decides to swap the page 
into its backing store and free the page.  The guest page structs (if 
any) would remain.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
