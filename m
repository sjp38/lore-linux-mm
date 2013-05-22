Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id BBCB06B00D1
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:53:57 -0400 (EDT)
Message-ID: <519CDC03.7070602@sr71.net>
Date: Wed, 22 May 2013 07:53:55 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 16/39] thp, mm: locking tail page is a bug
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-17-git-send-email-kirill.shutemov@linux.intel.com> <519BD69E.5000207@sr71.net> <20130522141245.F047CE0090@blue.fi.intel.com>
In-Reply-To: <20130522141245.F047CE0090@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2013 07:12 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>
>>> Locking head page means locking entire compound page.
>>> If we try to lock tail page, something went wrong.
>>
>> Have you actually triggered this in your development?
> 
> Yes, on early prototypes.

I'd mention this in the description, and think about how necessary this
is with your _current_ code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
