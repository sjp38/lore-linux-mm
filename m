Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1BBF36B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 00:36:38 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id gb30so277266vcb.26
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 21:36:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50BCA2E4.8050600@suse.cz>
References: <50B52E17.8020205@suse.cz>
	<1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
	<50BCA2E4.8050600@suse.cz>
Date: Wed, 12 Dec 2012 13:36:36 +0800
Message-ID: <CAA_GA1dZm7LYe46vdurFf8avbSViPeT2jC_L0A3Oejg97RsmBA@mail.gmail.com>
Subject: Re: [PATCH 0/2] kernel BUG at mm/huge_memory.c:212!
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Dec 3, 2012 at 9:02 PM, Jiri Slaby <jslaby@suse.cz> wrote:
> On 11/30/2012 04:03 PM, Kirill A. Shutemov wrote:
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>
>> Hi Jiri,
>>
>> Sorry for late answer. It took time to reproduce and debug the issue.
>>
>> Could you test two patches below by thread. I expect it to fix both
>> issues: put_huge_zero_page() and Bad rss-counter state.
>
> Hi, yes, since applying the patches on the last Thu, it didn't recur.
>
>> Kirill A. Shutemov (2):
>>   thp: fix anononymous page accounting in fallback path for COW of HZP
>>   thp: avoid race on multiple parallel page faults to the same page
>>
>>  mm/huge_memory.c | 30 +++++++++++++++++++++++++-----
>>  1 file changed, 25 insertions(+), 5 deletions(-)
>

I still saw this bug on 3.7.0-rc8, but it's hard to reproduce it.
It appears only once.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
