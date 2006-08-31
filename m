Received: by wx-out-0506.google.com with SMTP id h28so713911wxd
        for <linux-mm@kvack.org>; Thu, 31 Aug 2006 11:41:05 -0700 (PDT)
Message-ID: <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
Date: Thu, 31 Aug 2006 20:41:04 +0200
From: "Haavard Skinnemoen" <hskinnemoen@gmail.com>
Subject: Re: [RFC][PATCH 2/9] conditionally define generic get_order() (ARCH_HAS_GET_ORDER)
In-Reply-To: <20060830221605.CFC342D7@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221605.CFC342D7@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 8/31/06, Dave Hansen <haveblue@us.ibm.com> wrote:
> diff -puN mm/Kconfig~generic-get_order mm/Kconfig
> --- threadalloc/mm/Kconfig~generic-get_order    2006-08-30 15:14:56.000000000 -0700
> +++ threadalloc-dave/mm/Kconfig 2006-08-30 15:15:00.000000000 -0700
> @@ -1,3 +1,7 @@
> +config ARCH_HAVE_GET_ORDER
> +       def_bool y
> +       depends on IA64 || PPC32 || XTENSA
> +

I have a feeling this has been discussed before, but wouldn't it be
better to let each architecture define this in its own Kconfig?

At some point, I have to add AVR32 to that list, and if one or more
other architectures need to do the same, there will be rejects.

Haavard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
