Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 4680F6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 13:28:02 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id dn14so8499311obc.32
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:28:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363665251-14377-1-git-send-email-linfeng@cn.fujitsu.com>
References: <CAE9FiQUrt11A0YAOLgvv3uTAWtTvVg3Mho9eD53orbxW6Jd8Vg@mail.gmail.com>
 <1363665251-14377-1-git-send-email-linfeng@cn.fujitsu.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 27 Mar 2013 11:27:41 -0600
Message-ID: <CAErSpo6DWfHii8d8rGPJ1dLj5TVzsgU7QGDoAvBM5Fb_N5=mtw@mail.gmail.com>
Subject: Re: [PATCH] kernel/range.c: subtract_range: fix the broken phrase
 issued by printk
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "x86@kernel.org" <x86@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>

On Mon, Mar 18, 2013 at 9:54 PM, Lin Feng <linfeng@cn.fujitsu.com> wrote:
> Also replace deprecated printk(KERN_ERR...) with pr_err() as suggested
> by Yinghai, attaching the function name to provide plenty info.
>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  kernel/range.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/kernel/range.c b/kernel/range.c
> index 9b8ae2d..071b0ab 100644
> --- a/kernel/range.c
> +++ b/kernel/range.c
> @@ -97,7 +97,8 @@ void subtract_range(struct range *range, int az, u64 start, u64 end)
>                                 range[i].end = range[j].end;
>                                 range[i].start = end;
>                         } else {
> -                               printk(KERN_ERR "run of slot in ranges\n");
> +                               pr_err("%s: run out of slot in ranges\n",
> +                                       __func__);
>                         }
>                         range[j].end = start;
>                         continue;

So now the user might see:

    subtract_range: run out of slot in ranges

What is the user supposed to do when he sees that?  If he happens to
mention it on LKML, what are we going to do about it?  If he attaches
the complete dmesg log, is there enough information to do something?

IMHO, that message is still totally useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
