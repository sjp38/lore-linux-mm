Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E456C6B32A8
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 15:22:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g63-v6so5734887pfc.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:22:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b35sor17138175plb.6.2018.11.23.12.22.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 12:22:32 -0800 (PST)
Date: Fri, 23 Nov 2018 12:22:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
In-Reply-To: <20181122090547.GD18011@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1811231211200.1964@eggly.anvils>
References: <20181120134323.13007-1-mhocko@kernel.org> <20181120134323.13007-4-mhocko@kernel.org> <alpine.LSU.2.11.1811201721470.2061@eggly.anvils> <20181121071132.GD12932@dhcp22.suse.cz> <alpine.LSU.2.11.1811211757070.5557@eggly.anvils>
 <20181122090547.GD18011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, 22 Nov 2018, Michal Hocko wrote:
> 
> If you want some update to the comment in this function or to the
> changelog, I am open of course. Right now I have
> +                * Check for a locked page first, as a speculative
> +                * reference may adversely influence page migration.
> as suggested by William.

I ought to care, since I challenged the significance of this aspect
in the first place, but find I don't care enough - I much prefer the
patch to the comments on and in it, but have not devised any wording
that I'd prefer to see instead - sorry.

Hugh
