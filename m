Date: Tue, 11 Sep 2007 14:19:00 +0300
Subject: Re: [ofa-general] [PATCH][RFC]: pte notifiers -- support for
	external page tables
Message-ID: <20070911111900.GJ1397@minantech.com>
References: <11890103283456-git-send-email-avi@qumranet.com> <20070906062441.GF3410@minantech.com> <46DFBBCC.8060307@qumranet.com> <46E58A4A.9080605@cray.com> <46E66FFE.2000204@quadrics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46E66FFE.2000204@quadrics.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel J Blueman <daniel.blueman@quadrics.com>
Cc: Avi Kivity <avi@qumranet.com>, Andrew Hastings <abh@cray.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 11, 2007 at 11:37:50AM +0100, Daniel J Blueman wrote:
> Andrew Hastings wrote:
>> Avi Kivity wrote:
>>> Gleb Natapov wrote:
>>>> On Wed, Sep 05, 2007 at 07:38:48PM +0300, Avi Kivity wrote:
>>>>  
>>>>> This sample patch adds a new mechanism, pte notifiers, that allows 
>>>>> drivers
>>>>> to register an interest in a changes to ptes. Whenever Linux changes a
>>>>> pte, it will call a notifier to allow the driver to adjust the external
>>>>> page table and flush its tlb.
>>>>>     
>>>> How is this different from http://lwn.net/Articles/133627/? AFAIR the
>>>> patch was rejected because there was only one user for it and it was
>>>> decided that it would be better to maintain it out of tree for a while.
>>>>   
>>>
>>> Your patch is more complete.
>>>
>>> There are now at least three users: you, kvm, and newer Infiniband HCAs.  
>>> Care to resurrect the patch?
>> We (Cray) also use the ioproc patch.  AFAIK the current maintainer is Dan 
>> Blueman at Quadrics.
>
> I should add that the IOPROC patches are maintained internally to loosely 
> track mainline kernels; however, we do not generally release [1] these 
> until they've passed quite a lot of validation (driven by customer demand 
> mostly) on various configurations.
>
> Quite a few large users/groups would benefit from this; the IOPROC patches 
> have been stable for quite a while now, so are a good option.
>
> If you have any feedback/suggestions that would help forward progress, I'm 
> happy to hear and address them.
>
Posting the patch against current kernel (-mm or mainline) here would
be certainly helpful.

Thanks,

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
