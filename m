Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEB838E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 13:50:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so29482587pfa.18
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 10:50:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q66si45313022pfb.231.2018.12.31.10.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Dec 2018 10:50:26 -0800 (PST)
Date: Mon, 31 Dec 2018 10:50:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v2 1/3] vmalloc: export __vmalloc_node_range for
 CONFIG_TEST_VMALLOC_MODULE
Message-ID: <20181231185022.GC6310@bombadil.infradead.org>
References: <20181231132640.21898-1-urezki@gmail.com>
 <20181231132640.21898-2-urezki@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181231132640.21898-2-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Dec 31, 2018 at 02:26:38PM +0100, Uladzislau Rezki (Sony) wrote:
> +#ifdef CONFIG_TEST_VMALLOC_MODULE
> +EXPORT_SYMBOL(__vmalloc_node_range);
> +#endif

Definitely needs to be _GPL.
