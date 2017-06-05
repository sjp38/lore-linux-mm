Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F02D6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 16:24:42 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z125so175312459itc.4
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 13:24:42 -0700 (PDT)
Received: from mail-it0-x22c.google.com (mail-it0-x22c.google.com. [2607:f8b0:4001:c0b::22c])
        by mx.google.com with ESMTPS id j11si12082132itj.98.2017.06.05.13.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 13:24:41 -0700 (PDT)
Received: by mail-it0-x22c.google.com with SMTP id m62so73721741itc.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 13:24:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170605192216.21596-4-igor.stoppa@huawei.com>
References: <20170605192216.21596-1-igor.stoppa@huawei.com> <20170605192216.21596-4-igor.stoppa@huawei.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 5 Jun 2017 22:24:20 +0200
Message-ID: <CAG48ez1VMPLasTypDX5QnZnYprbCXfG9ZP9jQvPpS=HCpgvHvQ@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 3/5] Protectable Memory Allocator -
 Debug interface
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Kees Cook <keescook@chromium.org>, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@i-love.sakura.ne.jp, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, casey@schaufler-ca.com, Christoph Hellwig <hch@infradead.org>, labbott@redhat.com, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Mon, Jun 5, 2017 at 9:22 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> Debugfs interface: it creates a file
>
> /sys/kernel/debug/pmalloc/pools
>
> which exposes statistics about all the pools and memory nodes in use.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
[...]
> +       seq_printf(s, " - node:\t\t%p\n", node);
> +       seq_printf(s, "   - start of data ptr:\t%p\n", node->data);
> +       seq_printf(s, "   - end of node ptr:\t%p\n", (void *)end_of_node);
[...]
> +       seq_printf(s, "pool:\t\t\t%p\n", pool);
[...]
> +       debugfs_create_file("pools", 0644, pmalloc_root, NULL,
> +                           &pmalloc_file_ops);

You should probably be using %pK to hide the kernel pointers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
