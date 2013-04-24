Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 4012A6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:49:49 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id to1so1659192ieb.39
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 23:49:48 -0700 (PDT)
Date: Wed, 24 Apr 2013 01:49:45 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2 6/6] add documentation on proc.txt
References: <1366767664-17541-1-git-send-email-minchan@kernel.org>
	<1366767664-17541-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1366767664-17541-7-git-send-email-minchan@kernel.org> (from
	minchan@kernel.org on Tue Apr 23 20:41:04 2013)
Message-Id: <1366786185.18069.160@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>

On 04/23/2013 08:41:04 PM, Minchan Kim wrote:
> This patch adds stuff about new reclaim field in proc.txt
>=20
> Cc: Rob Landley <rob@landley.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>=20
> Rob, I didn't add your Acked-by because interface was slight changed.
> I hope you give Acke-by after review again.
> Thanks.
>=20
>  Documentation/filesystems/proc.txt | 22 ++++++++++++++++++++++
>  mm/Kconfig                         |  7 +------
>  2 files changed, 23 insertions(+), 6 deletions(-)
>=20
> diff --git a/Documentation/filesystems/proc.txt =20
> b/Documentation/filesystems/proc.txt
> index 488c094..1411ad0 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -136,6 +136,7 @@ Table 1-1: Process specific entries in /proc
>   maps		Memory maps to executables and library files	=20
> (2.4)
>   mem		Memory held by this process
>   root		Link to the root directory of this process
> + reclaim	Reclaim pages in this process
>   stat		Process status
>   statm		Process memory status information
>   status		Process status in human readable form
> @@ -489,6 +490,27 @@ To clear the soft-dirty bit
>=20
>  Any other value written to /proc/PID/clear_refs will have no effect.
>=20
> +The file /proc/PID/reclaim is used to reclaim pages in this process.
> +To reclaim file-backed pages,
> +    > echo file > /proc/PID/reclaim
> +
> +To reclaim anonymous pages,
> +    > echo anon > /proc/PID/reclaim
> +
> +To reclaim all pages,
> +    > echo all > /proc/PID/reclaim
> +
> +Also, you can specify address range of process so part of address =20
> space
> +will be reclaimed. The format is following as
> +    > echo addr size-byte > /proc/PID/reclaim
> +
> +NOTE: addr should be page-aligned.

And size in bytes should be a multiple of page size?

> +
> +Below is example which try to reclaim 2 pages from 0x100000.
> +
> +To reclaim both pages in address range,
> +    > echo $((1<<20) 8192 > /proc/PID/reclaim

Would you like to balance your parentheses?

Acked-by: Rob Landley <rob@landley.net>

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
