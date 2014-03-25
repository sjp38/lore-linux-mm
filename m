Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4E36B003C
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:06:06 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so784417pad.14
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:06:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f1si11860115pbn.317.2014.03.25.11.06.05
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 11:06:05 -0700 (PDT)
Message-ID: <5331C1C9.5020309@intel.com>
Date: Tue, 25 Mar 2014 10:50:01 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: move FAULT_AROUND_ORDER to arch/
References: <1395730215-11604-1-git-send-email-maddy@linux.vnet.ibm.com> <1395730215-11604-2-git-send-email-maddy@linux.vnet.ibm.com> <20140325173605.GA21411@node.dhcp.inet.fi>
In-Reply-To: <20140325173605.GA21411@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On 03/25/2014 10:36 AM, Kirill A. Shutemov wrote:
>> > +/*
>> > + * Fault around order is a control knob to decide the fault around pages.
>> > + * Default value is set to 0UL (disabled), but the arch can override it as
>> > + * desired.
>> > + */
>> > +#ifndef FAULT_AROUND_ORDER
>> > +#define FAULT_AROUND_ORDER	0UL
>> > +#endif
> FAULT_AROUND_ORDER == 0 case should be handled separately in
> do_read_fault(): no reason to go to do_fault_around() if we are going to
> fault in only one page.

Isn't this the kind of thing we want to do in Kconfig?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
