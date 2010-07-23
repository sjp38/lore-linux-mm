Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F3246B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 04:18:17 -0400 (EDT)
Received: by vws16 with SMTP id 16so1417240vws.14
        for <linux-mm@kvack.org>; Fri, 23 Jul 2010 01:18:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C49468B.40307@vflare.org>
References: <20100621231809.GA11111@ca-server1.us.oracle.com>
	<4C49468B.40307@vflare.org>
Date: Fri, 23 Jul 2010 17:17:49 +0900
Message-ID: <AANLkTi=W4xpz1VP9oPbK3pNY-5aODydzsAhuAWv-1+Vt@mail.gmail.com>
Subject: Re: [PATCH V3 0/8] Cleancache: overview
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 4:36 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>
> 2. I think change in btrfs can be avoided by moving cleancache_get_page()
> from do_mpage_reapage() to filemap_fault() and this should work for all
> filesystems. See:
>
> handle_pte_fault() -> do_(non)linear_fault() -> __do_fault()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0-> vma->vm_ops->fault()
>
> which is defined as filemap_fault() for all filesystems. If some future
> filesystem uses its own custom function (why?) then it will have to arran=
ge for
> call to cleancache_get_page(), if it wants this feature.


filemap fault works only in case of file-backed page which is mapped
but don't work not-mapped cache page.  So we could miss cache page by
read system call if we move it into filemap_fault.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
