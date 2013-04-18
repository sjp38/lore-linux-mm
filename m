Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B92F46B0027
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:42:21 -0400 (EDT)
Message-ID: <51702267.3040205@sr71.net>
Date: Thu, 18 Apr 2013 09:42:15 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of do_huge_linear_fault()
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com> <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com> <51631206.3060605@sr71.net> <20130417143842.1A76CE0085@blue.fi.intel.com> <516F1D3C.1060804@sr71.net> <20130418160920.4A00DE0085@blue.fi.intel.com> <51701D5E.80802@sr71.net> <20130418163836.B73B2E0085@blue.fi.intel.com>
In-Reply-To: <20130418163836.B73B2E0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 04/18/2013 09:38 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 04/18/2013 09:09 AM, Kirill A. Shutemov wrote:
>>> Dave Hansen wrote:
>>>> On 04/17/2013 07:38 AM, Kirill A. Shutemov wrote:
>>>> Are you still sure you can't do _any_ better than a verbatim copy of 129
>>>> lines?
>>>
>>> It seems I was too lazy. Shame on me. :(
>>> Here's consolidated version. Only build tested. Does it look better?
>>
>> Yeah, it's definitely a step in the right direction.  There rae
>> definitely some bugs in there like:
>>
>> +	unsigned long haddr = address & PAGE_MASK;
> 
> It's not bug. It's bad name for the variable.
> See, first 'if (try_huge_pages)'. I update it there for huge page case.
> 
> addr_aligned better?

That's a criminally bad name. :)

addr_aligned is better, and also please initialize the two cases
together.  It's mean to separate them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
