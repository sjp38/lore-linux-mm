Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9F56B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:56:26 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id b13so8502788wgh.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 03:56:26 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id z2si19277338wib.91.2015.01.26.03.56.24
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 03:56:25 -0800 (PST)
Date: Mon, 26 Jan 2015 13:56:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm] WARNING: CPU: 1 PID: 681 at mm/mmap.c:2858 exit_mmap()
Message-ID: <20150126115612.GA25833@node.dhcp.inet.fi>
References: <20150125043608.GB6109@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150125043608.GB6109@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 24, 2015 at 08:36:08PM -0800, Fengguang Wu wrote:
> [   17.687075] Freeing unused kernel memory: 1716K (c190d000 - c1aba000)
> [   17.808897] random: init urandom read with 5 bits of entropy available
> [   17.828360] ------------[ cut here ]------------
> [   17.828989] WARNING: CPU: 1 PID: 681 at mm/mmap.c:2858 exit_mmap+0x197/0x1ad()
> [   17.830086] Modules linked in:
> [   17.830549] CPU: 1 PID: 681 Comm: init Not tainted 3.19.0-rc5-gf7a7b53 #19
> [   17.831339]  00000001 00000000 00000001 d388bd4c c14341a1 00000000 00000001 c16ebf08
> [   17.832421]  d388bd68 c1056987 00000b2a c1150db8 00000001 00000001 00000000 d388bd78
> [   17.833488]  c1056a11 00000009 00000000 d388bdd0 c1150db8 d3858380 ffffffff ffffffff
> [   17.841323] Call Trace:
> [   17.844215]  [<c14341a1>] dump_stack+0x78/0xa8
> [   17.844700]  [<c1056987>] warn_slowpath_common+0xb7/0xce
> [   17.847797]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
> [   17.850955]  [<c1056a11>] warn_slowpath_null+0x14/0x18
> [   17.854131]  [<c1150db8>] exit_mmap+0x197/0x1ad
> [   17.854629]  [<c10537ff>] mmput+0x52/0xef
> [   17.857584]  [<c1175602>] flush_old_exec+0x923/0x99d
> [   17.860806]  [<c11aea1e>] load_elf_binary+0x430/0x11af
> [   17.861378]  [<c108559f>] ? local_clock+0x2f/0x39
> [   17.865327]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
> [   17.866002]  [<c1174159>] search_binary_handler+0x9c/0x20f
> [   17.866588]  [<c11ac7e5>] load_script+0x339/0x355
> [   17.874149]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
> [   17.874718]  [<c108559f>] ? local_clock+0x2f/0x39
> [   17.878580]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
> [   17.879355]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
> [   17.879997]  [<c1174159>] search_binary_handler+0x9c/0x20f
> [   17.887644]  [<c1176054>] do_execveat_common+0x6d6/0x954
> [   17.890904]  [<c11762eb>] do_execve+0x19/0x1b
> [   17.891389]  [<c1176586>] SyS_execve+0x21/0x25
> [   17.895168]  [<c143be92>] syscall_call+0x7/0x7
> [   17.895653] ---[ end trace 6a7094e9a1d04ce0 ]---
> [   17.909585] ------------[ cut here ]------------

Thanks for report. The patch below should fix this.
