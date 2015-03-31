Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id D5A946B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 06:01:11 -0400 (EDT)
Received: by lbcmq2 with SMTP id mq2so8537075lbc.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 03:01:11 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id f2si8897127laa.142.2015.03.31.03.01.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 03:01:10 -0700 (PDT)
Received: by lahf3 with SMTP id f3so8221647lah.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 03:01:09 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] mm/mmap.c: use while instead of if+goto
References: <1427744435-6304-1-git-send-email-linux@rasmusvillemoes.dk>
	<20150330205413.GA4458@node.dhcp.inet.fi>
	<20150330145821.ca638ac21a02564cb5c04a36@linux-foundation.org>
Date: Tue, 31 Mar 2015 12:01:07 +0200
In-Reply-To: <20150330145821.ca638ac21a02564cb5c04a36@linux-foundation.org>
	(Andrew Morton's message of "Mon, 30 Mar 2015 14:58:21 -0700")
Message-ID: <87wq1xh4f0.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Roman Gushchin <klamm@yandex-team.ru>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 30 2015, Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 30 Mar 2015 23:54:13 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> On Mon, Mar 30, 2015 at 09:40:35PM +0200, Rasmus Villemoes wrote:
>> > The creators of the C language gave us the while keyword. Let's use
>> > that instead of synthesizing it from if+goto.
>> > 
>> > Made possible by 6597d783397a ("mm/mmap.c: replace find_vma_prepare()
>> > with clearer find_vma_links()").
>> > 
>> > Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>> 
>> 
>> Looks good, except both your plus-lines are over 80-characters long for no
>> reason.
>
> --- a/mm/mmap.c~mm-mmapc-use-while-instead-of-ifgoto-fix
> +++ a/mm/mmap.c
> @@ -1551,7 +1551,8 @@ unsigned long mmap_region(struct file *f
>
> I'm not sure it improves things a lot, but mmap.c has been pretty
> careful about the 80-col thing...

Yeah, I did run checkpatch and chose to ignore the 80-col warning, since
I think both the patch and the resulting code was more readable that
way. I don't really care either way, though.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
