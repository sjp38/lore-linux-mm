Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B5D826B0082
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 18:21:02 -0500 (EST)
Received: by qyk14 with SMTP id 14so7575433qyk.11
        for <linux-mm@kvack.org>; Wed, 06 Jan 2010 15:21:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1262795169-9095-3-git-send-email-mel@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
	 <1262795169-9095-3-git-send-email-mel@csn.ul.ie>
Date: Wed, 6 Jan 2010 15:21:01 -0800
Message-ID: <eada2a071001061521t53dff44bkaf54dab058b1d01b@mail.gmail.com>
Subject: Re: [PATCH 2/7] Export unusable free space index via
	/proc/pagetypeinfo
From: Tim Pepper <lnxninja@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 6, 2010 at 8:26 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 6051fba..e1ea2d5 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -451,6 +451,104 @@ static int frag_show(struct seq_file *m, void *arg)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +
> +struct config_page_info {
> + =A0 =A0 =A0 unsigned long free_pages;
> + =A0 =A0 =A0 unsigned long free_blocks_total;
> + =A0 =A0 =A0 unsigned long free_blocks_suitable;
> +};
> +
> +/*
> + * Calculate the number of free pages in a zone, how many contiguous
> + * pages are free and how many are large enough to satisfy an allocation=
 of
> + * the target size. Note that this function makes to attempt to estimate

s/makes to/makes no/    ?



Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
