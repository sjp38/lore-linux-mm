Message-ID: <46E58A4A.9080605@cray.com>
Date: Mon, 10 Sep 2007 13:17:46 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: [ofa-general] [PATCH][RFC]: pte notifiers -- support for	external
 page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <20070906062441.GF3410@minantech.com> <46DFBBCC.8060307@qumranet.com>
In-Reply-To: <46DFBBCC.8060307@qumranet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Daniel Blueman <daniel.blueman@quadrics.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Gleb Natapov wrote:
>> On Wed, Sep 05, 2007 at 07:38:48PM +0300, Avi Kivity wrote:
>>  
>>> This sample patch adds a new mechanism, pte notifiers, that allows 
>>> drivers
>>> to register an interest in a changes to ptes. Whenever Linux changes a
>>> pte, it will call a notifier to allow the driver to adjust the external
>>> page table and flush its tlb.
>>>     
>> How is this different from http://lwn.net/Articles/133627/? AFAIR the
>> patch was rejected because there was only one user for it and it was
>> decided that it would be better to maintain it out of tree for a while.
>>   
> 
> Your patch is more complete.
> 
> There are now at least three users: you, kvm, and newer Infiniband 
> HCAs.  Care to resurrect the patch?

We (Cray) also use the ioproc patch.  AFAIK the current maintainer is 
Dan Blueman at Quadrics.

-Andrew Hastings
  Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
