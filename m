Message-ID: <46DFBBCC.8060307@qumranet.com>
Date: Thu, 06 Sep 2007 11:35:24 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [ofa-general] [PATCH][RFC]: pte notifiers -- support for	external
 page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <20070906062441.GF3410@minantech.com>
In-Reply-To: <20070906062441.GF3410@minantech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: lkml@qumranet.com, linux-mm@kvack.org, kvm@qumranet.com, shaohua.li@intel.com, general@lists.openfabrics.org, addy@quadrics.com
List-ID: <linux-mm.kvack.org>

Gleb Natapov wrote:
> On Wed, Sep 05, 2007 at 07:38:48PM +0300, Avi Kivity wrote:
>   
>> This sample patch adds a new mechanism, pte notifiers, that allows drivers
>> to register an interest in a changes to ptes. Whenever Linux changes a
>> pte, it will call a notifier to allow the driver to adjust the external
>> page table and flush its tlb.
>>     
> How is this different from http://lwn.net/Articles/133627/? AFAIR the
> patch was rejected because there was only one user for it and it was
> decided that it would be better to maintain it out of tree for a while.
>   

Your patch is more complete.

There are now at least three users: you, kvm, and newer Infiniband 
HCAs.  Care to resurrect the patch?

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
