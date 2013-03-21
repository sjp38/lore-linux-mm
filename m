Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 4C4266B0027
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:25:11 -0400 (EDT)
Message-ID: <514B269F.8090701@sr71.net>
Date: Thu, 21 Mar 2013 08:26:23 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 03/30] mm: drop actor argument of do_generic_file_read()
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-4-git-send-email-kirill.shutemov@linux.intel.com> <CAJd=RBAKGiCb_+yoFog6xao5bF8vqFwE9MGZ9EVbf1fe-dXnDQ@mail.gmail.com> <20130315132246.F0542E0085@blue.fi.intel.com>
In-Reply-To: <20130315132246.F0542E0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/15/2013 06:22 AM, Kirill A. Shutemov wrote:
> Hillf Danton wrote:
>> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>>>
>>> There's only one caller of do_generic_file_read() and the only actor is
>>> file_read_actor(). No reason to have a callback parameter.
>>>
>> This cleanup is not urgent if it nukes no barrier for THP cache.
> 
> Yes, it's not urgent. On other hand it can be applied upstream right now ;)

If someone might pick this up and merge it right away, it's probably
best to put it very first in the series and call it out as such to the
person you expect to pick it up, or even send it up to them separately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
