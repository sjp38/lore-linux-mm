Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id EEBE06B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 05:34:20 -0500 (EST)
Received: by obbta7 with SMTP id ta7so5161827obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 02:34:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56cc3c5d40a8653b7d9bef856ff02d909b98f36f.1326803859.git.leonid.moiseichuk@nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
	<56cc3c5d40a8653b7d9bef856ff02d909b98f36f.1326803859.git.leonid.moiseichuk@nokia.com>
Date: Wed, 18 Jan 2012 12:34:19 +0200
Message-ID: <CAOJsxLHfHHrFyhfkSe8mbsnJHBkgKtksCZZDwN6K3d7KJqfzkQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] Making si_swapinfo exportable
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Tue, Jan 17, 2012 at 3:22 PM, Leonid Moiseichuk
<leonid.moiseichuk@nokia.com> wrote:
> If we will make si_swapinfo() exportable it could be called from modules.
> Otherwise modules have no interface to obtain information about swap usag=
e.
> Change made in the same way as si_meminfo() declared.
>
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
> ---
> =A0mm/swapfile.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index b1cd120..192cc25 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -5,10 +5,12 @@
> =A0* =A0Swap reorganised 29.12.95, Stephen Tweedie
> =A0*/
>
> +#include <linux/export.h>
> =A0#include <linux/mm.h>
> =A0#include <linux/hugetlb.h>
> =A0#include <linux/mman.h>
> =A0#include <linux/slab.h>
> +#include <linux/kernel.h>
> =A0#include <linux/kernel_stat.h>
> =A0#include <linux/swap.h>
> =A0#include <linux/vmalloc.h>
> @@ -2177,6 +2179,7 @@ void si_swapinfo(struct sysinfo *val)
> =A0 =A0 =A0 =A0val->totalswap =3D total_swap_pages + nr_to_be_unused;
> =A0 =A0 =A0 =A0spin_unlock(&swap_lock);
> =A0}
> +EXPORT_SYMBOL(si_swapinfo);

FWIW, I'm completely OK with this export:

  Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
