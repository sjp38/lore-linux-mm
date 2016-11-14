Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 252876B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:20:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so37272530pfg.4
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:20:10 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l7si24039324pgl.92.2016.11.14.15.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:20:08 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id y68so6817895pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:20:08 -0800 (PST)
Subject: Re: [PATCH v7 2/5] mm: remove x86-only restriction of movable_node
References: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1479160961-25840-3-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <37a9339f-0ce9-261f-90de-be8463705bb5@gmail.com>
Date: Tue, 15 Nov 2016 10:20:00 +1100
MIME-Version: 1.0
In-Reply-To: <1479160961-25840-3-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org



On 15/11/16 09:02, Reza Arbab wrote:
> In commit c5320926e370 ("mem-hotplug: introduce movable_node boot
> option"), the memblock allocation direction is changed to bottom-up and
> then back to top-down like this:
> 
> 1. memblock_set_bottom_up(true), called by cmdline_parse_movable_node().
> 2. memblock_set_bottom_up(false), called by x86's numa_init().
> 
> Even though (1) occurs in generic mm code, it is wrapped by #ifdef
> CONFIG_MOVABLE_NODE, which depends on X86_64.
> 
> This means that when we extend CONFIG_MOVABLE_NODE to non-x86 arches,
> things will be unbalanced. (1) will happen for them, but (2) will not.
> 
> This toggle was added in the first place because x86 has a delay between
> adding memblocks and marking them as hotpluggable. Since other arches do
> this marking either immediately or not at all, they do not require the
> bottom-up toggle.
> 
> So, resolve things by moving (1) from cmdline_parse_movable_node() to
> x86's setup_arch(), immediately after the movable_node parameter has
> been parsed.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>


Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
