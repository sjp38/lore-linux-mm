Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC6A16B0294
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 19:04:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id b132-v6so379041iti.2
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 16:04:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w9-v6sor3289227itb.46.2018.07.02.16.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 16:04:10 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com> <CA+55aFzyUb07Lt251bzi4T79oB=M8uypFQ2m__FgnRJUauqd0Q@mail.gmail.com>
In-Reply-To: <CA+55aFzyUb07Lt251bzi4T79oB=M8uypFQ2m__FgnRJUauqd0Q@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Jul 2018 16:03:59 -0700
Message-ID: <CA+55aFxZM9JeOeMkksZR93LojhvPZC38QnyvDEdazYg2SG2qHQ@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 2, 2018 at 3:54 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Lookie here, for example:
>
>   [torvalds@i7 linux]$ strace -e trace=%file -c git status

So in the name of honestly, that's slightly misleading.

"git" will happily thread the actual index file up-to-date testing.

And that's hidden in the above numbers (because I didn't use "-f" to
follow threads), and they are all successful (because git will go an
'lstat()' on every single entry in the index file, and the index file
obviously is all valid filenames).

So the numbers quoted are closer to the

        git ls-files -o --exclude-standard

command (which doesn't check the index state, it only checks "what
non-tracked files do I have that aren't the ones I explicitly
exclude").

            Linus
