Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 10CD66B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:49:41 -0500 (EST)
Message-ID: <50FD7FA9.6080901@redhat.com>
Date: Mon, 21 Jan 2013 12:49:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
References: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
In-Reply-To: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On 01/20/2013 10:15 PM, paul.szabo@sydney.edu.au wrote:
> When calculating amount of dirtyable memory, min_free_kbytes should be
> subtracted because it is not intended for dirty pages.
>
> Using an "extern int" because that is the only interface to some such
> sysctl values.
>
> (This patch does not solve the PAE OOM issue.)
>
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
>
> Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
> Reference: http://bugs.debian.org/695182
> Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
