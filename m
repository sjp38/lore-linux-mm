Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id F0FC46B00E8
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 13:01:30 -0400 (EDT)
Received: by werj55 with SMTP id j55so1271647wer.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:01:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120331092915.19920.14205.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg> <20120331092915.19920.14205.stgit@zurg>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 31 Mar 2012 10:01:08 -0700
Message-ID: <CA+55aFwsmREkwBHuP_atBm7FJ76J=WjDj8aQsne85gbX9Sk19w@mail.gmail.com>
Subject: Re: [PATCH 3/7] mm: kill vma flag VM_CAN_NONLINEAR
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On Sat, Mar 31, 2012 at 2:29 AM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This patch moves actual ptes filling for non-linear file mappings
> into special vma operation: ->remap_pages().
>
> Now fs must implement this method to get non-linear mappings support.
> If fs uses filemap_fault() then it can use generic_file_remap_pages() for this.

Me likee.

The other patches in the series look ok too, but this one in
particular is definitely the right thing, and an example of how people
have just used vm_flags bits for all the wrong reasons.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
