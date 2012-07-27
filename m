Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5D6816B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:17:22 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so953779wgb.2
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:17:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50126D44.7070608@cn.fujitsu.com>
References: <50126B83.3050201@cn.fujitsu.com>
	<50126D44.7070608@cn.fujitsu.com>
Date: Fri, 27 Jul 2012 13:17:20 -0700
Message-ID: <CA+8MBbL+G=xqkWU4xGF3_Ra7KoeoHuzL6QYcRiKqtVZoOBfLdQ@mail.gmail.com>
Subject: Re: [RFC PATCH v5 05/19] memory-hotplug: check whether memory is
 present or not
From: Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

On Fri, Jul 27, 2012 at 3:28 AM, Wen Congyang <wency@cn.fujitsu.com> wrote:
> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
> +{
> +       int i;
> +       for (i = 0; i < nr_pages; i++) {
> +               if (pfn_present(pfn + 1))

Typo? I think you meant "pfn + i"

> +                       continue;
> +               else
> +                       return -EINVAL;
> +       }
> +       return 0;
> +}

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
