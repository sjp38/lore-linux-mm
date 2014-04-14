Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id A41606B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 17:08:40 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8738115pbb.33
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 14:08:40 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id hi3si9542310pac.123.2014.04.14.14.08.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 14:08:39 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so8456326pdj.6
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 14:08:39 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20140414154911.GH3308@sgi.com>
References: <CAHO5Pa0VCzR7oqNXkwELuAsNQnnvF8Xoo=CuCaM64-GzjDuoFA@mail.gmail.com>
 <20140414154911.GH3308@sgi.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 14 Apr 2014 23:08:16 +0200
Message-ID: <CAKgNAkicfxhdsa_fa6MCOR-UtbjzYaTv2gRzWq2qKHCuYHc3KA@mail.gmail.com>
Subject: Re: Documenting prctl() PR_SET_THP_DISABLE and PR_GET_THP_DISABLE
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>

On Mon, Apr 14, 2014 at 5:49 PM, Alex Thorlton <athorlton@sgi.com> wrote:
> On Mon, Apr 14, 2014 at 12:15:01PM +0200, Michael Kerrisk wrote:
>> Alex,
>>
>> Your commit a0715cc22601e8830ace98366c0c2bd8da52af52 added the prctl()
>> PR_SET_THP_DISABLE and PR_GET_THP_DISABLE flags.
>>
>> The text below attempts to document these flags for the prctl(3).
>> Could you (and anyone else who is willing) please review the text
>> below (one or two p[ieces of which are drawn from your commit message)
>> to verify that it accurately reflects reality and your intent, and
>> that I have not missed any significant details.
>
> Looks fine to me!

Thanks, Alex.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
