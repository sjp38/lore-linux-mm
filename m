Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id BDBC56B0083
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:01 -0400 (EDT)
Received: by weys10 with SMTP id s10so5681304wey.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:31:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120731103724.20515.60334.stgit@zurg>
References: <20120731103724.20515.60334.stgit@zurg>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2012 09:31:27 -0700
Message-ID: <CA+55aFxxCUOd0ec36mnVB1a93UvOuqsTLOPpJGMsZ2ChudwE1Q@mail.gmail.com>
Subject: Re: [PATCH RESEND v3 00/10] mm: vma->vm_flags diet
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Jul 31, 2012 at 3:41 AM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
>
> This patchset kills some VM_* flags in vma->vm_flags,
> as result there appears five free bits.

All of these patches make sense and look good to me. I assume I'll get
this through Andrew for 3.7?

Andrew, you can consider them all ack'ed.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
