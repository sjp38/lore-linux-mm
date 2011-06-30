Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE4A86B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:41:15 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2884055pzk.14
        for <linux-mm@kvack.org>; Thu, 30 Jun 2011 15:41:13 -0700 (PDT)
Date: Fri, 1 Jul 2011 01:40:19 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
Message-ID: <20110630224019.GC2544@shale.localdomain>
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, kvm@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org

On Thu, Jun 30, 2011 at 12:01:08PM -0700, Dan Magenheimer wrote:
> +static int zv_curr_dist_counts_show(char *buf)
> +{
> +	unsigned long i, n, chunks = 0, sum_total_chunks = 0;
> +	char *p = buf;
> +
> +	for (i = 0; i <= NCHUNKS - 1; i++) {

It's more common to write the condition as:  i < NCHUNKS.


> +		n = zv_curr_dist_counts[i];

zv_curr_dist_counts has NCHUNKS + 1 elements so we never print
display the final element.  I don't know this coe, so I could be
wrong but I think that we could make zv_curr_dist_counts only hold
NCHUNKS elements.

> +		p += sprintf(p, "%lu ", n);
> +		chunks += n;
> +		sum_total_chunks += i * n;
> +	}
> +	p += sprintf(p, "mean:%lu\n",
> +		chunks == 0 ? 0 : sum_total_chunks / chunks);
> +	return p - buf;
> +}
> +
> +static int zv_cumul_dist_counts_show(char *buf)
> +{
> +	unsigned long i, n, chunks = 0, sum_total_chunks = 0;
> +	char *p = buf;
> +
> +	for (i = 0; i <= NCHUNKS - 1; i++) {
> +		n = zv_cumul_dist_counts[i];

Same situation.

> +		p += sprintf(p, "%lu ", n);
> +		chunks += n;
> +		sum_total_chunks += i * n;
> +	}
> +	p += sprintf(p, "mean:%lu\n",
> +		chunks == 0 ? 0 : sum_total_chunks / chunks);
> +	return p - buf;
> +}
> +

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
