Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 667F98E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:35:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id t10so1560792plo.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:35:50 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id ce19si20653036plb.13.2019.01.23.06.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:35:49 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 1/2] x86: respect memory size limiting via mem= parameter
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190122080628.7238-2-jgross@suse.com>
Date: Wed, 23 Jan 2019 07:35:28 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <69D0866F-77A7-4529-A01E-12395106E22D@oracle.com>
References: <20190122080628.7238-1-jgross@suse.com>
 <20190122080628.7238-2-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de



> On Jan 22, 2019, at 1:06 AM, Juergen Gross <jgross@suse.com> wrote:
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b9a667d36c55..7fc2a87110a3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -96,10 +96,16 @@ void mem_hotplug_done(void)
> 	cpus_read_unlock();
> }
> 
> +u64 max_mem_size = -1;

This may be pedantic, but I'd rather see U64_MAX used here.
