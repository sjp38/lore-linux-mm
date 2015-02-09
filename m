Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id ECE1F6B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 11:42:59 -0500 (EST)
Received: by labgd6 with SMTP id gd6so5646719lab.7
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 08:42:59 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id xg5si6204541lbb.148.2015.02.09.08.42.57
        for <linux-mm@kvack.org>;
        Mon, 09 Feb 2015 08:42:57 -0800 (PST)
Date: Mon, 9 Feb 2015 18:42:48 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: BUG: non-zero nr_pmds on freeing mm: 1
Message-ID: <20150209164248.GA29522@node.dhcp.inet.fi>
References: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Pat Erley <pat-lkml@erley.org>, Linux-Next <linux-next@vger.kernel.org>, kirill.shutemov@linux.intel.com, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Feb 07, 2015 at 08:33:02AM +0100, Sedat Dilek wrote:
> On Sat, Feb 7, 2015 at 6:12 AM, Pat Erley <pat-lkml@erley.org> wrote:
> > I'm seeing the message in $subject on my Xen DOM0 on next-20150204 on
> > x86_64.  I haven't had time to bisect it, but have seen some discussion on
> > similar topics here recently.  I can trigger this pretty reliably by
> > watching Netflix.  At some point (minutes to hours) into it, the netflix
> > video goes black (audio keeps going, so it still thinks it's working) and
> > the error appears in dmesg.  Refreshing the page gets the video going again,
> > and it will continue playing for some indeterminate amount of time.
> >
> > Kirill, I've CC'd you as looking in the logs, you've patched a false
> > positive trigger of this very recently(patch in kernel I'm running).  Am I
> > actually hitting a problem, or is this another false positive case? Any
> > additional details that might help?
> >
> > Dmesg from system attached.
> 
> [ CC some mm folks ]
> 
> I have seen this, too.
> 
> root# grep "BUG: non-zero nr_pmds on freeing mm:" /var/log/kern.log | wc -l
> 21
> 
> Checking my logs: On next-20150203 and next-20150204.
> 
> I am here not in a VM environment and cannot say what causes these messages.

Sorry, my fault.

The patch below should fix that.
