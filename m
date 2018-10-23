Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0DA6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 02:13:13 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a8-v6so144808wrr.16
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 23:13:13 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id m66-v6si480785wmm.192.2018.10.22.23.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 23:13:11 -0700 (PDT)
Date: Tue, 23 Oct 2018 07:13:09 +0100 (BST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
In-Reply-To: <20181023053359.GL18839@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810230711220.2343@hadrien>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org> <20181022181122.GK18839@dhcp22.suse.cz> <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com> <20181023053359.GL18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun Sudhilal <getarunks@gmail.com>, Arun KS <arunks@codeaurora.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>



On Tue, 23 Oct 2018, Michal Hocko wrote:

> [Trimmed CC list + Julia - there is indeed no need to CC everybody maintain a
> file you are updating for the change like this]
>
> On Tue 23-10-18 10:16:51, Arun Sudhilal wrote:
> > On Mon, Oct 22, 2018 at 11:41 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 22-10-18 22:53:22, Arun KS wrote:
> > > > Remove managed_page_count_lock spinlock and instead use atomic
> > > > variables.
> > >
> >
> > Hello Michal,
> > > I assume this has been auto-generated. If yes, it would be better to
> > > mention the script so that people can review it and regenerate for
> > > comparision. Such a large change is hard to review manually.
> >
> > Changes were made partially with script.  For totalram_pages and
> > totalhigh_pages,
> >
> > find dir -type f -exec sed -i
> > 's/totalram_pages/atomic_long_read(\&totalram_pages)/g' {} \;
> > find dir -type f -exec sed -i
> > 's/totalhigh_pages/atomic_long_read(\&totalhigh_pages)/g' {} \;
> >
> > For managed_pages it was mostly manual edits after using,
> > find mm/ -type f -exec sed -i
> > 's/zone->managed_pages/atomic_long_read(\&zone->managed_pages)/g' {}
> > \;
>
> I guess we should be able to use coccinelle for this kind of change and
> reduce the amount of manual intervention to absolute minimum.

Coccinelle looks like it would be desirable, especially in case the word
zone is not always used.

Arun, please feel free to contact me if you want to try it and need help.

julia
