Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4E0C6B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:49:07 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so299608930pac.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:49:07 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id a13si19011708pfc.215.2016.05.02.08.49.07
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 08:49:07 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <572766A7.9090406@suse.cz>
 <20160502150109.GB24419@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <572776EF.2070804@intel.com>
Date: Mon, 2 May 2016 08:49:03 -0700
MIME-Version: 1.0
In-Reply-To: <20160502150109.GB24419@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 05/02/2016 08:01 AM, Kirill A. Shutemov wrote:
> On Mon, May 02, 2016 at 04:39:35PM +0200, Vlastimil Babka wrote:
>> On 04/27/2016 07:11 PM, Dave Hansen wrote:
>>> 6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
>>>    severity of the problem.
>>
>> I think that makes sense. Being large already amortizes the cost per base
>> page much more than pagevecs do (512 vs ~22 pages?).
> 
> We try to do this already, don't we? Any spefic case where we have THPs on
> pagevecs?

Lukas was hitting this on a RHEL 7 era kernel.  In his kernel at least,
I'm pretty sure THP's were ending up on pagevecs.  Are you saying you
don't think we're doing that any more?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
