From: Ed Tomlinson <edt@aei.ca>
Subject: Re: 2.6.1-mm4
Date: Fri, 16 Jan 2004 08:45:16 -0500
References: <20040115225948.6b994a48.akpm@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Message-Id: <200401160845.17199.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On January 16, 2004 01:59 am, Andrew Morton wrote:
> - There's a patch here which changes the ia32 CPU type selection.  Make
>   sure you go in there and select the right CPU type(s), else the kernel
>   won't compile.   We might need to set a default here.
>
> - Kernel NFS server update
>
> - MD update
>
> - V4L update
>
> - A string of fixes against the parport, paride and associated drivers
>
> - Update to the latest UML
>
> - Patches to support gcc-3.4 on ia32.  There is more to do here - more
>   warnings need to be fixed and the exception tables need to be sorted.  I
>   didn't add the `-Winline' patch because it's way too noisy at present.

Hi Andrew,

Doing a modules install with mm4 gets a nfsd.ko needs unknown symbol dnotify_parent

Ideas?
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
