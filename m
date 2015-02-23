Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 288D66B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:24:15 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id va2so39753457obc.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:24:15 -0800 (PST)
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com. [209.85.214.180])
        by mx.google.com with ESMTPS id e196si2445115oig.105.2015.02.23.14.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 14:24:14 -0800 (PST)
Received: by mail-ob0-f180.google.com with SMTP id vb8so39587063obc.11
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:24:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424728954.6539.49.camel@stgolabs.net>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-2-git-send-email-dbueso@suse.de>
	<1424658000.6539.14.camel@stgolabs.net>
	<1579072.xrgTk0Bmz6@sifl>
	<1424728954.6539.49.camel@stgolabs.net>
Date: Mon, 23 Feb 2015 17:24:13 -0500
Message-ID: <CAHC9VhS_gxBhUA2tffpC_kK4C=bWKH3a3VhHk+YbkCgE7Sb_oQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Paul Moore <paul@paul-moore.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-audit@redhat.com

On Mon, Feb 23, 2015 at 5:02 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> On Mon, 2015-02-23 at 16:59 -0500, Paul Moore wrote:
>> Merged into audit#next.
>
> hmm Andrew I was hoping you could take these patches. That way we can
> easily build on top. Let me know if you think otherwise, as I've got
> more ready to send out with a similar email scheme.

FWIW, I merged these two patches into the audit#next branch because
they are contained to audit and have value regardless of what else
happens during this development cycle.  It is just linux-next after
all, not Linus tree so if I need to drop the patches later I can do
that easily enough.  I'd rather get more exposure to the patches than
less, and getting into linux-next now helps that.

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
