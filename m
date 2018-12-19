Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF23B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:55:25 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id j13so190349oii.8
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:55:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 70sor12389727otm.187.2018.12.19.12.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 12:55:24 -0800 (PST)
MIME-Version: 1.0
References: <154510700291.1941238.817190985966612531.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181219203236.GA5689@dhcp22.suse.cz>
In-Reply-To: <20181219203236.GA5689@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Dec 2018 12:55:13 -0800
Message-ID: <CAPcyv4iiH_TfAra9F+v-NruuGAHPhp_oRH3Ut3gFZAjM=Mesyg@mail.gmail.com>
Subject: Re: [PATCH v6 0/6] mm: Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Keith Busch <keith.busch@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andy Lutomirski <luto@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Wed, Dec 19, 2018 at 12:32 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 17-12-18 20:23:23, Dan Williams wrote:
> > Andrew, this needs at least an ack from Michal, or Mel before it moves
> > forward. It would be a nice surprise / present to see it move forward
> > before the holidays, but I suspect it may need to simmer until the new
> > year. This series is against v4.20-rc6.
>
> I am sorry but I am unlikely to look into this before the end of the
> year and I do not want to promise early days in new year either because
> who knows how much stuff piles up by then. But this is definitely on my
> radar.

Ok, I'll hold off on posting v7 until the 4.21/5.0 -rc2 timeframe.
