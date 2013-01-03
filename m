Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 057046B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 00:49:20 -0500 (EST)
Message-ID: <50E51BDA.8020102@redhat.com>
Date: Thu, 03 Jan 2013 00:49:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] mm: remove flags argument to mmap_region
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-8-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-8-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> After the MAP_POPULATE handling has been moved to mmap_region() call sites,
> the only remaining use of the flags argument is to pass the MAP_NORESERVE
> flag. This can be just as easily handled by do_mmap_pgoff(), so do that
> and remove the mmap_region() flags parameter.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
