Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 49FC26B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 10:37:27 -0500 (EST)
Received: by mail-vb0-f44.google.com with SMTP id fc26so508696vbb.17
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 07:37:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
References: <20130105152208.GA3386@redhat.com> <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils> <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com> <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 8 Jan 2013 07:37:06 -0800
Message-ID: <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
Subject: Re: oops in copy_page_rep()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 8, 2013 at 5:04 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Tue, Jan 8, 2013 at 1:34 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Hmm. Is there some reason we never need to worry about it for the
>> "pmd_numa()" case just above?
>>
>> A comment about this all might be a really good idea.
>>
> Yes Sir, added.

Heh. I was more thinking about why do_huge_pmd_wp_page() needs it, but
do_huge_pmd_numa_page() does not.

Also, do we actually need it for huge_pmd_set_accessed()? The
*placement* of that thing confuses me. And because it confuses me, I'd
like to understand it.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
