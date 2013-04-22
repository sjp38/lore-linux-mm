Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 1EA656B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:48:45 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id ar20so7369895iec.28
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:48:44 -0700 (PDT)
Date: Mon, 22 Apr 2013 10:48:39 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH 6/6] add documentation on proc.txt
References: <1366620306-30940-1-git-send-email-minchan@kernel.org>
	<1366620306-30940-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1366620306-30940-6-git-send-email-minchan@kernel.org> (from
	minchan@kernel.org on Mon Apr 22 03:45:06 2013)
Message-Id: <1366645719.18069.147@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>

On 04/22/2013 03:45:06 AM, Minchan Kim wrote:
> This patch adds documentation about new reclaim field in proc.txt
>=20
> Cc: Rob Landley <rob@landley.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/filesystems/proc.txt | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>=20
> diff --git a/Documentation/filesystems/proc.txt =20
> b/Documentation/filesystems/proc.txt
> index 488c094..c1f5ee4 100644
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
> @@ -489,6 +490,29 @@ To clear the soft-dirty bit
>=20
>  Any other value written to /proc/PID/clear_refs will have no effect.
>=20
> +The /proc/PID/reclaim is used to reclaim pages in this process.

Trivial nitpick: Either start with "The file" or just /proc/PID/reclaim

> +To reclaim file-backed pages,
> +    > echo 1 > /proc/PID/reclaim
> +
> +To reclaim anonymous pages,
> +    > echo 2 > /proc/PID/reclaim
> +
> +To reclaim both pages,
> +    > echo 3 > /proc/PID/reclaim
> +
> +Also, you can specify address range of process so part of address =20
> space
> +will be reclaimed. The format is following as
> +    > echo 4 addr size > /proc/PID/reclaim

Size is in bytes or pages? (I'm guessing bytes. It must be a multiple =20
of pages?)

So the following examples are telling it to reclaim a specific page?

> +To reclaim file-backed pages in address range,
> +    > echo 4 $((1<<20) 4096 > /proc/PID/reclaim
> +
> +To reclaim anonymous pages in address range,
> +    > echo 5 $((1<<20) 4096 > /proc/PID/reclaim
> +
> +To reclaim both pages in address range,
> +    > echo 6 $((1<<20) 4096 > /proc/PID/reclaim
> +
>  The /proc/pid/pagemap gives the PFN, which can be used to find the =20
> pageflags
>  using /proc/kpageflags and number of times a page is mapped using
>  /proc/kpagecount. For detailed explanation, see =20
> Documentation/vm/pagemap.txt.

Otherwise, if the series goes in I'm fine with this going in with it.

Acked-by: Rob Landley <rob@landley.net>

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
