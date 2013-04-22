Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 201FC6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 12:17:20 -0400 (EDT)
Message-ID: <51756286.4020704@intel.com>
Date: Mon, 22 Apr 2013 09:17:10 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] add documentation on proc.txt
References: <1366620306-30940-1-git-send-email-minchan@kernel.org> <1366620306-30940-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1366620306-30940-6-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Rob Landley <rob@landley.net>

On 04/22/2013 01:45 AM, Minchan Kim wrote:
> +The /proc/PID/reclaim is used to reclaim pages in this process.
> +To reclaim file-backed pages,
> +    > echo 1 > /proc/PID/reclaim
> +
> +To reclaim anonymous pages,
> +    > echo 2 > /proc/PID/reclaim
> +
> +To reclaim both pages,
> +    > echo 3 > /proc/PID/reclaim

This seems to be in the same spirit as /proc/sys/vm/drop_caches.  That's
not a sin in and of itself.  But, why use numbers here?

Any chance I could talk you in to using some strings, say like:

	echo 'anonymous' > /proc/PID/reclaim
	echo 'anonymous|file' > /proc/PID/reclaim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
