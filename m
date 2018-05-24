Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 631216B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:12:32 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id w10-v6so513110otj.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:12:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4-v6sor9931307ote.124.2018.05.24.01.12.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 01:12:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180523182404.11433-2-david@redhat.com>
References: <20180523182404.11433-1-david@redhat.com> <20180523182404.11433-2-david@redhat.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 24 May 2018 10:12:30 +0200
Message-ID: <CAJZ5v0jar8TqC5MGRPcAVZfM3LmmoSV3fT3Sgok=r6D9cDG0+w@mail.gmail.com>
Subject: Re: [PATCH RFCv2 1/4] ACPI: NUMA: export pxm_to_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Wed, May 23, 2018 at 8:24 PM, David Hildenbrand <david@redhat.com> wrote:
> Will be needed by paravirtualized memory devices.

That's a little information.

It would be good to see the entire series at least.

> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org>
> Cc: linux-acpi@vger.kernel.org
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/acpi/numa.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index 85167603b9c9..7ffee2959350 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -50,6 +50,7 @@ int pxm_to_node(int pxm)
>                 return NUMA_NO_NODE;
>         return pxm_to_node_map[pxm];
>  }
> +EXPORT_SYMBOL(pxm_to_node);

EXPORT_SYMBOL_GPL(), please.

>
>  int node_to_pxm(int node)
>  {
> --
