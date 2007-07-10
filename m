From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
Date: Mon, 9 Jul 2007 19:54:10 -0500
References: <4692D616.4010004@oracle.com>
In-Reply-To: <4692D616.4010004@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200707091954.10502.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 09 July 2007, Herbert van den Bergh wrote:
> With this patch, not only memory in the data segment of a process, but
> also private data mappings, both file-based and anonymous, are counted
> toward the RLIMIT_DATA resource limit.  Executable mappings, such as
> text segments of shared objects, are not counted toward the private data
> limit.  The result is that malloc() will fail once the combined size of
> the data segment and private data mappings reaches this limit.
>
> This brings the Linux behavior in line with what is documented in the
> POSIX man page for setrlimit(3p).

I believe this patch is a simple and obvious fix to a hole introduced when 
libc malloc() began using mmap() instead of brk().  We took away the ability 
to control how much data space processes could soak up.  This patch returns 
that control to the user.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
