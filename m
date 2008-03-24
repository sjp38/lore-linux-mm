Received: by rn-out-0910.google.com with SMTP id i24so1761052rng.0
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 10:39:33 -0700 (PDT)
Message-ID: <4cefeab80803241039n829edeexa141089c40a08a57@mail.gmail.com>
Date: Mon, 24 Mar 2008 23:09:33 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [PATCH 2/6] compcache: block device - internal defs
In-Reply-To: <200803241725.59726.m.kozlowski@tuxland.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803242033.30782.nitingupta910@gmail.com>
	 <200803241725.59726.m.kozlowski@tuxland.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 9:55 PM, Mariusz Kozlowski
<m.kozlowski@tuxland.pl> wrote:
> Hi Nitin,
>
>
>  >  +#define K(x)   ((x) >> 10)
>  >  +#define KB(x)  ((x) << 10)
>
>  Hm. These look cryptic unless you remember what they do.
>  Could have better names?

I'll give them better names/add comments.

>
>
>  > +#define CC_DEBUG2((fmt,arg...) \
>  > +       printk(KERN_DEBUG C fmt,##arg)
>
>  Unbalanced parenthesis.
>

Corrected. Thanks.

- Nitin

>  Just my 0.05zl.
>
>         Mariusz
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
