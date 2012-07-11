Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BA24B6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 22:45:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1486151pbb.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 19:45:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120709141225.GA17314@barrios>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
	<20120709082200.GX14154@suse.de>
	<20120709084657.GA7915@bbox>
	<jtek81$ja5$1@dough.gmane.org>
	<20120709141225.GA17314@barrios>
Date: Wed, 11 Jul 2012 10:45:31 +0800
Message-ID: <CAM_iQpWbPywocE+phUTbp+DJrZdFEM_Y85Lj37_Tdzj976CaTw@mail.gmail.com>
Subject: Re: [PATCH] mm: Warn about costly page allocation
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 9, 2012 at 10:12 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Embedded can use CONFIG_PRINTK and !CONFIG_BUG for size optimization
> and printk(pr_xxx) + dump_stack is common technic used in all over kernel
> sources. Do you have any reason you don't like it?
>

No, I am just feeling like it is a kind of dup. No objections from me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
