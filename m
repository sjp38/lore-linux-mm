Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2987F6B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:33:55 -0400 (EDT)
Message-ID: <51769BD1.7070002@intel.com>
Date: Tue, 23 Apr 2013 07:33:53 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] add documentation on proc.txt
References: <1366620306-30940-1-git-send-email-minchan@kernel.org> <1366620306-30940-6-git-send-email-minchan@kernel.org> <51756286.4020704@intel.com> <20130423015349.GC2603@blaptop>
In-Reply-To: <20130423015349.GC2603@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Rob Landley <rob@landley.net>, Namhyung Kim <namhyung@kernel.org>

On 04/22/2013 06:53 PM, Minchan Kim wrote:
> echo 'file' > /proc/PID/reclaim
> echo 'anon' > /proc/PID/reclaim
> echo 'both' > /proc/PID/reclaim
> 
> For range reclaim,
> 
> echo $((1<<20)) 8192 > /proc/PID/reclaim.
> 
> IOW, we don't need any type for range reclaim because only thing
> user takes care is address range which has mapped page regardless
> of that it's anon or file.
> 
> Does it make sense to you?

That looks very nice!  Although, I'd probably use 'all' instead of
'both'.  It leaves you more wiggle room to add more types in the future,
like volatile pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
