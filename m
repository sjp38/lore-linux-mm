Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F24DE6B0075
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 01:03:59 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so10940629pad.2
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 22:03:59 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id ta1si461255pab.359.2014.04.01.22.03.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 22:03:59 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Wed, 2 Apr 2014 15:03:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 37F393578047
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:03:53 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3253Zgi59834478
	for <linux-mm@kvack.org>; Wed, 2 Apr 2014 16:03:39 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s324jk3o023906
	for <linux-mm@kvack.org>; Wed, 2 Apr 2014 15:45:46 +1100
Message-ID: <533B95F6.2010303@linux.vnet.ibm.com>
Date: Wed, 02 Apr 2014 10:15:42 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: move FAULT_AROUND_ORDER to arch/
References: <1395730215-11604-1-git-send-email-maddy@linux.vnet.ibm.com> <1395730215-11604-2-git-send-email-maddy@linux.vnet.ibm.com> <20140325173605.GA21411@node.dhcp.inet.fi> <5331C1C9.5020309@intel.com>
In-Reply-To: <5331C1C9.5020309@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On Tuesday 25 March 2014 11:20 PM, Dave Hansen wrote:
> On 03/25/2014 10:36 AM, Kirill A. Shutemov wrote:
>>>> +/*
>>>> + * Fault around order is a control knob to decide the fault around pages.
>>>> + * Default value is set to 0UL (disabled), but the arch can override it as
>>>> + * desired.
>>>> + */
>>>> +#ifndef FAULT_AROUND_ORDER
>>>> +#define FAULT_AROUND_ORDER	0UL
>>>> +#endif
>> FAULT_AROUND_ORDER == 0 case should be handled separately in
>> do_read_fault(): no reason to go to do_fault_around() if we are going to
>> fault in only one page.
> 
> Isn't this the kind of thing we want to do in Kconfig?
> 
> 
I am still investigating this option since this looks better. But it is
taking time, my bad. I will get back on this.

With Regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
