Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 879C86B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 22:09:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q8-v6so13557662ioh.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 19:09:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w142-v6sor8869372ita.25.2018.05.21.19.09.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 19:09:52 -0700 (PDT)
MIME-Version: 1.0
References: <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
 <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com> <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com> <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
 <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com> <CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
 <20180522002239.GA4860@bombadil.infradead.org> <CAKOZuevBprpJ-fVKGCmuQz3dTMjKRfqp-cUuCyUzdkuQTQRNoQ@mail.gmail.com>
 <20180522011920.GA29393@thunk.org> <CAKOZuev5kMc88VOvwELv4aAwKB0n2x+uiSK8-XcNHstABcc=7w@mail.gmail.com>
In-Reply-To: <CAKOZuev5kMc88VOvwELv4aAwKB0n2x+uiSK8-XcNHstABcc=7w@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 19:09:39 -0700
Message-ID: <CAKOZuesxPVwcovzvQoas=hGvN3heiV08Rxf6J3MYZfTxvRBJ0A@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu
Cc: willy@infradead.org, dave.hansen@intel.com, linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 6:41 PM Daniel Colascione <dancol@google.com> wrote:
> That'd be good too, but I don't see how this guarantee would be easier to
> make. If you call mmap three times, those three allocations might end up
> merged into the same VMA, and if you called munmap on the middle
> allocation, you'd still have to split. Am I misunderstanding something?

Oh: a sequence number stored in the VMA, combined with a refusal to merge
across sequence number differences.
