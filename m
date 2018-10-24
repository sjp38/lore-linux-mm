Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CECA6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 02:15:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d17-v6so1974351pls.22
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:15:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t33-v6si3773193pgk.141.2018.10.23.23.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 23:15:51 -0700 (PDT)
Date: Wed, 24 Oct 2018 08:15:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Message-ID: <20181024061546.GY18839@dhcp22.suse.cz>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com>
 <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
 <CAGXu5j+NsDHRWA5PKAKeJCO_oiGkFAUeWE8O-1fEBQX80MDu1A@mail.gmail.com>
 <7a4fcbaee7efb71d2a3c6b403c090db4@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a4fcbaee7efb71d2a3c6b403c090db4@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Kees Cook <keescook@chromium.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Arun Sudhilal <getarunks@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 24-10-18 10:47:52, Arun KS wrote:
> On 2018-10-24 01:34, Kees Cook wrote:
[...]
> > Thank you -- I was struggling to figure out the best way to reply to
> > this. :)
> I'm sorry for the trouble caused. Sent the email using,
> git send-email  --to-cmd="scripts/get_maintainer.pl -i"
> 0001-convert-totalram_pages-totalhigh_pages-and-managed_p.patch
> 
> Is this not a recommended approach?

Not really for tree wide mechanical changes. It is much more preferrable
IMHO to only CC people who should review the intention of the change
rather than each and every maintainer whose code is going to be changed.
This is a case by case thing of course but as soon as you see a giant CC
list from get_maintainer.pl then you should try to think twice to use
it. If not sure, just ask on the mailing list.

-- 
Michal Hocko
SUSE Labs
