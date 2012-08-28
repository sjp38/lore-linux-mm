Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 0FC2C6B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 16:25:11 -0400 (EDT)
Date: Tue, 28 Aug 2012 13:24:59 -0700
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] kmemleak: avoid buffer overrun: NUL-terminate
 strncpy-copied command
Message-ID: <20120828202459.GA13638@mwanda>
References: <1345481724-30108-1-git-send-email-jim@meyering.net>
 <1345481724-30108-4-git-send-email-jim@meyering.net>
 <20120824102725.GH7585@arm.com>
 <876288o7ny.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <876288o7ny.fsf@rho.meyering.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Meyering <jim@meyering.net>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Aug 24, 2012 at 01:23:29PM +0200, Jim Meyering wrote:
> In that case, what would you think of a patch to use strcpy instead?
> 
>   -		strncpy(object->comm, current->comm, sizeof(object->comm));
>   +		strcpy(object->comm, current->comm);

Another option would be to use strlcpy().  It's slightly neater than
the strncpy() followed by a NUL assignment.

> 
> Is there a preferred method of adding a static_assert-like statement?
> I see compile_time_assert and a few similar macros, but I haven't
> spotted anything that is used project-wide.

BUILD_BUG_ON().

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
