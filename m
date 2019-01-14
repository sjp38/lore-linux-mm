Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 945328E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:12:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so468323pgq.9
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:12:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m1si1554335pgi.218.2019.01.14.15.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:12:13 -0800 (PST)
Subject: Re: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-3-git-send-email-kernelfans@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a5fe4d86-3551-7da8-caca-fdd497ace99f@intel.com>
Date: Mon, 14 Jan 2019 15:12:12 -0800
MIME-Version: 1.0
In-Reply-To: <1547183577-20309-3-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On 1/10/19 9:12 PM, Pingfan Liu wrote:
> The current acpi_table_upgrade() relies on initrd_start, but this var is

"var" meaning variable?

Could you please go back and try to ensure you spell out all the words
you are intending to write?  I think "topo" probably means "topology",
but it's a really odd word to use for changing the arguments of a
function, so I'm not sure.

There are a couple more of these in this set.

> only valid after relocate_initrd(). There is requirement to extract the
> acpi info from initrd before memblock-allocator can work(see [2/4]), hence
> acpi_table_upgrade() need to accept the input param directly.

"[2/4]"

It looks like you quickly resent this set without updating the patch
descriptions.

> diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> index 61203ee..84e0a79 100644
> --- a/drivers/acpi/tables.c
> +++ b/drivers/acpi/tables.c
> @@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
>  
>  #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
>  
> -void __init acpi_table_upgrade(void)
> +void __init acpi_table_upgrade(void *data, size_t size)
>  {
> -	void *data = (void *)initrd_start;
> -	size_t size = initrd_end - initrd_start;
>  	int sig, no, table_nr = 0, total_offset = 0;
>  	long offset = 0;
>  	struct acpi_table_header *table;

I know you are just replacing some existing variables, but we have a
slightly higher standard for naming when you actually have to specify
arguments to a function.  Can you please give these proper names?
