Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 635E06B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 19:06:06 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so176455eek.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:06:05 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id 45si14562601eeh.243.2014.05.06.16.06.04
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 16:06:04 -0700 (PDT)
Date: Wed, 7 May 2014 02:03:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
Message-ID: <20140506230323.GA14821@node.dhcp.inet.fi>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
 <CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Tue, May 06, 2014 at 02:51:24PM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 2:35 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Tue,  6 May 2014 17:37:24 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> >
> >> This patchset replaces the syscall with emulation which creates new VMA on
> >> each remap and remove code to support non-linear mappings.
> >>
> >> Nonlinear mappings are pain to support and it seems there's no legitimate
> >> use-cases nowadays since 64-bit systems are widely available.
> >>
> >> It's not yet ready to apply. Just to give rough idea of what can we get if
> >> we'll deprecated remap_file_pages().
> >>
> >> I need to split patches properly and write correct commit messages. And there's
> >> still code to remove.
> >
> > hah.  That's bold.  It would be great if we can get away with this.
> >
> > Do we have any feeling for who will be impacted by this and how badly?
> 
> I *would* love to get rid of the nonlinear mappings, but I really have
> zero visibility into who ended up using it. I assume it's a "Oracle on
> 32-bit x86" kind of thing.

There're funny PyPy people who wants to use remap_file_pages() in new code to
build software transaction memory[1]. It sounds just crazy to me.

[1] https://lwn.net/Articles/587923/

> I think this is more of a distro question. Plus perhaps an early patch
> to just add a warning first so that we can see who it triggers for?

Something like this?
