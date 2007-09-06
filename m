Date: Thu, 6 Sep 2007 11:41:51 +0300
Subject: Re: [ofa-general] [PATCH][RFC]: pte notifiers -- support for
	external page tables
Message-ID: <20070906084151.GK3410@minantech.com>
References: <11890103283456-git-send-email-avi@qumranet.com> <20070906062441.GF3410@minantech.com> <46DFBBCC.8060307@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46DFBBCC.8060307@qumranet.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: lkml@qumranet.com, linux-mm@kvack.org, kvm@qumranet.com, shaohua.li@intel.com, general@lists.openfabrics.org, addy@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Sep 06, 2007 at 11:35:24AM +0300, Avi Kivity wrote:
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
> There are now at least three users: you, kvm, and newer Infiniband HCAs.  
> Care to resurrect the patch?
>
This is not my patch :) This is patch written by David Addison from
Quadrics. I CCed him on my previous email. I just saw that you are
trying to do something similar.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
