Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD75C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:25:43 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id u63so3512505oie.17
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:25:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m110sor1082525otc.176.2019.01.17.08.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:25:42 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-12-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-12-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 17:25:30 +0100
Message-ID: <CAJZ5v0hYx_fG6UW+MXfLtdBAyWc_qi4A0h5xVTpTSAbo4ntz7g@mail.gmail.com>
Subject: Re: [PATCHv4 11/13] Documentation/ABI: Add node cache attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Add the attributes for the system memory side caches.

I really would combine this with the previous one.

> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 34 +++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 2217557f29d3..613d51fb52a3 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -142,3 +142,37 @@ Contact:   Keith Busch <keith.busch@intel.com>
>  Description:
>                 This node's write latency in nanoseconds available to memory
>                 initiators in nodes found in this class's initiators_nodelist.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/associativity
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The caches associativity: 0 for direct mapped, non-zero if
> +               indexed.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/level
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This cache's level in the memory hierarchy. Matches 'Y' in the
> +               directory name.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/line_size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The number of bytes accessed from the next cache level on a
> +               cache miss.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/size
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The size of this memory side cache in bytes.
> +
> +What:          /sys/devices/system/node/nodeX/side_cache/indexY/write_policy
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The cache write policy: 0 for write-back, 1 for write-through,
> +               2 for other or unknown.
> --

It would be good to document the meaning of indexY itself too.
