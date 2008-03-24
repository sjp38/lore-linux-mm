From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PATCH 2/6] compcache: block device - internal defs
Date: Mon, 24 Mar 2008 17:25:59 +0100
References: <200803242033.30782.nitingupta910@gmail.com>
In-Reply-To: <200803242033.30782.nitingupta910@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200803241725.59726.m.kozlowski@tuxland.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nitingupta910@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

>  +#define K(x)   ((x) >> 10)
>  +#define KB(x)  ((x) << 10)

Hm. These look cryptic unless you remember what they do.
Could have better names?

> +#define CC_DEBUG2((fmt,arg...) \
> +       printk(KERN_DEBUG C fmt,##arg)

Unbalanced parenthesis.

Just my 0.05zl.

	Mariusz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
