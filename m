Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE2F66B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 12:02:35 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x5-v6so997688pln.21
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:02:35 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o7si403137pgp.527.2018.04.09.09.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 09:02:34 -0700 (PDT)
Subject: Re: [PATCH v3 2/4] mm/sparsemem: Defer the ms->section_mem_map
 clearing
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-3-bhe@redhat.com>
 <8e147320-50f5-f809-31d2-992c35ecc418@intel.com>
 <20180408065055.GA19345@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fa2bb08a-42cc-c0cc-31c0-39d6e14f6f92@intel.com>
Date: Mon, 9 Apr 2018 09:02:31 -0700
MIME-Version: 1.0
In-Reply-To: <20180408065055.GA19345@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 04/07/2018 11:50 PM, Baoquan He wrote:
>> Should the " = 0" instead be clearing SECTION_MARKED_PRESENT or
>> something?  That would make it easier to match the code up with the code
>> that it is effectively undoing.
> 
> Not sure if I understand your question correctly. From memory_present(),
> information encoded into ms->section_mem_map including numa node,
> SECTION_IS_ONLINE and SECTION_MARKED_PRESENT. Not sure if it's OK to only
> clear SECTION_MARKED_PRESENT.  People may wrongly check SECTION_IS_ONLINE
> and do something on this memory section?

What is mean is that, instead of:

	
	ms->section_mem_map = 0;

we could literally do:

	ms->section_mem_map &= ~SECTION_MARKED_PRESENT;

That does the same thing in practice, but makes the _intent_ much more
clear.
