Received: by fg-out-1718.google.com with SMTP id e12so2367899fga.4
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 23:00:35 -0700 (PDT)
Date: Tue, 25 Mar 2008 08:57:52 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 08/10] net: remove NR_CPUS arrays in net/core/dev.c
Message-ID: <20080325055752.GA4774@martell.zuzino.mipt.ru>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com> <20080325021956.212787000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325021956.212787000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Patrick McHardy <kaber@trash.net>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 07:20:02PM -0700, Mike Travis wrote:
> Remove the fixed size channels[NR_CPUS] array in
> net/core/dev.c and dynamically allocate array based on
> nr_cpu_ids.

> @@ -4362,6 +4362,13 @@ netdev_dma_event(struct dma_client *clie
>   */
>  static int __init netdev_dma_register(void)
>  {
> +	net_dma.channels = kzalloc(nr_cpu_ids * sizeof(struct net_dma),
> +								GFP_KERNEL);
> +	if (unlikely(net_dma.channels)) {

		     !net_dma.channels

> +		printk(KERN_NOTICE
> +				"netdev_dma: no memory for net_dma.channels\n");
> +		return -ENOMEM;
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
