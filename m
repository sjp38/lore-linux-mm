Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB04A8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 11:56:16 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id u73-v6so8554738lja.4
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 08:56:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor28013943lja.17.2019.01.01.08.56.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 08:56:15 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Tue, 1 Jan 2019 17:55:57 +0100
Subject: Re: [RFC v2 1/3] vmalloc: export __vmalloc_node_range for
 CONFIG_TEST_VMALLOC_MODULE
Message-ID: <20190101165557.z2ocf6fmjzh73dyp@pc636>
References: <20181231132640.21898-1-urezki@gmail.com>
 <20181231132640.21898-2-urezki@gmail.com>
 <20181231185022.GC6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181231185022.GC6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Dec 31, 2018 at 10:50:22AM -0800, Matthew Wilcox wrote:
> On Mon, Dec 31, 2018 at 02:26:38PM +0100, Uladzislau Rezki (Sony) wrote:
> > +#ifdef CONFIG_TEST_VMALLOC_MODULE
> > +EXPORT_SYMBOL(__vmalloc_node_range);
> > +#endif
> 
> Definitely needs to be _GPL.
Will upload updated variant. 

Thanks for the comment!

--
Vlad Rezki
