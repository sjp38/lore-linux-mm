Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02E856B0010
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 14:00:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s14-v6so13538086ioc.0
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 11:00:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2-v6sor1269436itg.105.2018.07.14.11.00.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 11:00:43 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com> <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
 <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz> <20180714173516.uumlhs4wgfgrlc32@devuan>
In-Reply-To: <20180714173516.uumlhs4wgfgrlc32@devuan>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 Jul 2018 11:00:32 -0700
Message-ID: <CA+55aFw1vrsTjJyoq4Q3jBwv1nXaTkkmSbHO6vozWZuTc7_6Kg@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Sat, Jul 14, 2018 at 10:35 AM Pavel Machek <pavel@ucw.cz> wrote:
>
> Could we allocate -ve entries from separate slab?

No, because negative dentrires don't stay negative.

Every single positive dentry starts out as a negative dentry that is
passed in to "lookup()" to maybe be made positive.

And most of the time they <i>do</i> turn positive, because most of the
time people actually open files that exist.

But then occasionally you don't, because you're just blindly opening a
filename whether it exists or not (to _check_ whether it's there).

              Linus
