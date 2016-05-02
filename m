Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 312EE6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:13:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so143529780lfd.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:13:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lf6si34682892wjc.111.2016.05.02.08.13.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 08:13:44 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <572766A7.9090406@suse.cz>
 <20160502150109.GB24419@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57276EA6.5090907@suse.cz>
Date: Mon, 2 May 2016 17:13:43 +0200
MIME-Version: 1.0
In-Reply-To: <20160502150109.GB24419@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 05/02/2016 05:01 PM, Kirill A. Shutemov wrote:
> On Mon, May 02, 2016 at 04:39:35PM +0200, Vlastimil Babka wrote:
>> On 04/27/2016 07:11 PM, Dave Hansen wrote:
>>> 6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
>>>     severity of the problem.
>>
>> I think that makes sense. Being large already amortizes the cost per base
>> page much more than pagevecs do (512 vs ~22 pages?).
>
> We try to do this already, don't we? Any spefic case where we have THPs on
> pagevecs?

For example like this?
__do_huge_pmd_anonymous_page
   lru_cache_add_active_or_unevictable
     lru_cache_add


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
