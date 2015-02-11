Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 31F93900015
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:59:22 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id a13so32461949igq.0
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:59:21 -0800 (PST)
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com. [209.85.223.169])
        by mx.google.com with ESMTPS id p191si1148281ioe.57.2015.02.11.09.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 09:59:21 -0800 (PST)
Received: by ierx19 with SMTP id x19so5905128ier.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:59:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 11 Feb 2015 09:59:21 -0800
Message-ID: <CA+55aFxGF+5qfSfa+JeUQscogT4uk0cu=y+R1WKqDFB9kZDK6Q@mail.gmail.com>
Subject: Re: [PATCH 0/4] Cleanup mm_populate() codepath
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, Feb 11, 2015 at 9:12 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> While reading mlock()- and mm_populate()-related code, I've found several
> things confusing. This patchset cleanup the codepath for future readers.

Looks sane to me. Ack.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
