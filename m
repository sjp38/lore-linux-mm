Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D20AB6B0273
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:39:22 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id k69-v6so4200221ite.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 01:39:22 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0084.hostedemail.com. [216.40.44.84])
        by mx.google.com with ESMTPS id v62-v6si987906itg.71.2018.10.24.01.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 01:39:21 -0700 (PDT)
Message-ID: <02a1bfc2eed324f3d03aa4a7b5eb6fde4e4a3bdd.camel@perches.com>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
From: Joe Perches <joe@perches.com>
Date: Wed, 24 Oct 2018 01:39:18 -0700
In-Reply-To: <20181024082312.GD18839@dhcp22.suse.cz>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
	 <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com>
	 <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
	 <CAGXu5j+NsDHRWA5PKAKeJCO_oiGkFAUeWE8O-1fEBQX80MDu1A@mail.gmail.com>
	 <7a4fcbaee7efb71d2a3c6b403c090db4@codeaurora.org>
	 <20181024061546.GY18839@dhcp22.suse.cz>
	 <0e1fc40af360ed55fd32784f6973af5940232f99.camel@perches.com>
	 <20181024082312.GD18839@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, Kees Cook <keescook@chromium.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Arun Sudhilal <getarunks@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2018-10-24 at 10:23 +0200, Michal Hocko wrote:
> On Tue 23-10-18 23:26:16, Joe Perches wrote:
> > On Wed, 2018-10-24 at 08:15 +0200, Michal Hocko wrote:
> > > On Wed 24-10-18 10:47:52, Arun KS wrote:
> > > > On 2018-10-24 01:34, Kees Cook wrote:
> > > [...]
> > > > > Thank you -- I was struggling to figure out the best way to reply to
> > > > > this. :)
> > > > I'm sorry for the trouble caused. Sent the email using,
> > > > git send-email  --to-cmd="scripts/get_maintainer.pl -i"
> > > > 0001-convert-totalram_pages-totalhigh_pages-and-managed_p.patch
> > > > 
> > > > Is this not a recommended approach?
> > > 
> > > Not really for tree wide mechanical changes. It is much more preferrable
> > > IMHO to only CC people who should review the intention of the change
> > > rather than each and every maintainer whose code is going to be changed.
> > > This is a case by case thing of course but as soon as you see a giant CC
> > > list from get_maintainer.pl then you should try to think twice to use
> > > it. If not sure, just ask on the mailing list.
> > 
> > Generally, it's better to use scripts to control
> > the --to-cmd and --cc-cmd options.
> 
> I would argue that it is better to use a common sense much more than
> scripts.

Common sense isn't common.

Perhaps you could describe some guidelines you
use to determine what you think is sensible to
send patches to maintainers and reviewers and
appropriate mailing lists.

Then compare those to the rules in the scripts
I suggested.

My suggestions:

o send to all top-level listed maintainers and
  reviewers in MAINTAINERS for the specific files
  in a patch
o cc all maintainers and reviewers that are upstream
  paths for the files in a patch
o cc all the upstream mailing lists for the files
  in the patch.
o do not generally use git-history to exclude authors
  of patches like drive-by/whitespace cleanups

Other advanced possibilities for patches that
modify specific and perhaps complex logic blocks:

o cc the people that are not maintainers that
  have modified the specific blocks or functions
