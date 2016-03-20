Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E5937830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:13:47 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id av4so71910877igc.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:13:47 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id i24si6166810iod.82.2016.03.20.12.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 12:13:47 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id z140so1188186iof.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:13:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160320190016.GD17997@ZenIV.linux.org.uk>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
	<20160320190016.GD17997@ZenIV.linux.org.uk>
Date: Sun, 20 Mar 2016 12:13:47 -0700
Message-ID: <CA+55aFzHPXcQT8XXy7=PAvaaN9d6uzu9JYN0nrtSPYWmr+=bWA@mail.gmail.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, Mar 20, 2016 at 12:00 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> It doesn't help legibility or testing, so let's just do it in one big go.
>
> Might make sense splitting it by the thing being removed, though - easier
> to visually verify that it's doing the right thing when all replacements
> are of the same sort...

Yeah, that might indeed make each patch easier to read, and if
something goes wrong (which looks unlikely, but hey, shit happens), it
also makes it easier to see just what went wrong.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
