Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2A8F6B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 01:50:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b16so7609417pfi.5
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 22:50:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si7876742pgp.370.2018.04.21.22.50.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Apr 2018 22:50:24 -0700 (PDT)
Subject: Re: [Xen-devel] [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
References: <bug-198497-200779@https.bugzilla.kernel.org/>
 <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org>
 <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
 <76a4ee3b-e00a-5032-df90-07d8e207f707@citrix.com>
 <5ADA0A6D02000078001BD177@prv1-mh.provo.novell.com>
 <CAKf6xps4RiC48zCie0o7VzTOCDu8ik1hmFP=b_qMx8qTo8F3TQ@mail.gmail.com>
 <5ADA0F1502000078001BD1D2@prv1-mh.provo.novell.com>
 <20180421143508.GB14610@bombadil.infradead.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <9b311a5f-1286-d3ed-fd42-d565dc7982ac@suse.com>
Date: Sun, 22 Apr 2018 07:50:17 +0200
MIME-Version: 1.0
In-Reply-To: <20180421143508.GB14610@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jan Beulich <JBeulich@suse.com>
Cc: Jason Andryuk <jandryuk@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-mm@kvack.org, akpm@linux-foundation.org, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, labbott@redhat.com

On 21/04/18 16:35, Matthew Wilcox wrote:
> On Fri, Apr 20, 2018 at 10:02:29AM -0600, Jan Beulich wrote:
>>>>>> Skylake 32bit PAE Dom0:
>>>>>> Bad swp_entry: 80000000
>>>>>> mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
>>>>>>
>>>>>> Ivy Bridge 32bit PAE Dom0:
>>>>>> Bad swp_entry: 40000000
>>>>>> mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
>>>>>>
>>>>>> Other 32bit DomU:
>>>>>> Bad swp_entry: 4000000
>>>>>> mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
>>>>>>
>>>>>> Other 32bit:
>>>>>> Bad swp_entry: 2000000
>>>>>> mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)
> 
>> As said in my previous reply - both of the bits Andrew has mentioned can
>> only ever be set when the present bit is also set (which doesn't appear to
>> be the case here). The set bits above are actually in the range of bits
>> designated to the address, which Xen wouldn't ever play with.
> 
> Is it relevant that all the crashes we've seen are with PAE in the guest?
> Is it possible that Xen thinks the guest is not using PAE?
> 

All Xen 32-bit PV guests are using PAE. Its part of the PV ABI.


Juergen
