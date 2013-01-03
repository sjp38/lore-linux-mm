Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 525A06B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 21:14:44 -0500 (EST)
Message-ID: <50E4E989.5090202@redhat.com>
Date: Wed, 02 Jan 2013 21:14:33 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/9] mm: introduce mm_populate() for populating new vmas
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-4-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-4-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> When creating new mappings using the MAP_POPULATE / MAP_LOCKED flags
> (or with MCL_FUTURE in effect), we want to populate the pages within the
> newly created vmas. This may take a while as we may have to read pages
> from disk, so ideally we want to do this outside of the write-locked
> mmap_sem region.
>
> This change introduces mm_populate(), which is used to defer populating
> such mappings until after the mmap_sem write lock has been released.
> This is implemented as a generalization of the former do_mlock_pages(),
> which accomplished the same task but was using during mlock() / mlockall().
>
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
