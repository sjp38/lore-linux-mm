Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6586B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 17:51:25 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so145092vcb.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:51:25 -0700 (PDT)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id up2si2552254vec.50.2014.05.06.14.51.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 14:51:25 -0700 (PDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so147252veb.1
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:51:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
Date: Tue, 6 May 2014 14:51:24 -0700
Message-ID: <CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Tue, May 6, 2014 at 2:35 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue,  6 May 2014 17:37:24 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>
>> This patchset replaces the syscall with emulation which creates new VMA on
>> each remap and remove code to support non-linear mappings.
>>
>> Nonlinear mappings are pain to support and it seems there's no legitimate
>> use-cases nowadays since 64-bit systems are widely available.
>>
>> It's not yet ready to apply. Just to give rough idea of what can we get if
>> we'll deprecated remap_file_pages().
>>
>> I need to split patches properly and write correct commit messages. And there's
>> still code to remove.
>
> hah.  That's bold.  It would be great if we can get away with this.
>
> Do we have any feeling for who will be impacted by this and how badly?

I *would* love to get rid of the nonlinear mappings, but I really have
zero visibility into who ended up using it. I assume it's a "Oracle on
32-bit x86" kind of thing.

I think this is more of a distro question. Plus perhaps an early patch
to just add a warning first so that we can see who it triggers for?

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
