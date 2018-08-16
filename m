Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3171D6B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:20:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t24-v6so1962810edq.13
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 07:20:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8-v6sor635125eds.43.2018.08.16.07.20.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 07:20:48 -0700 (PDT)
Date: Thu, 16 Aug 2018 17:20:44 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/4] mm: proc/pid/smaps_rollup: convert to single value
 seq_file
Message-ID: <20180816142044.GB15817@avx2>
References: <20180723111933.15443-1-vbabka@suse.cz>
 <20180723111933.15443-5-vbabka@suse.cz>
 <cb1d1965-9a13-e80f-dfde-a5d3bf9f510c@suse.cz>
 <20180726162637.GB25227@avx2>
 <bf4525b0-fd5b-4c4c-2cb3-adee3dd95a48@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bf4525b0-fd5b-4c4c-2cb3-adee3dd95a48@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, Jul 30, 2018 at 10:53:53AM +0200, Vlastimil Babka wrote:
> On 07/26/2018 06:26 PM, Alexey Dobriyan wrote:
> > On Wed, Jul 25, 2018 at 08:53:53AM +0200, Vlastimil Babka wrote:
> >> I moved the reply to this thread since the "added to -mm tree"
> >> notification Alexey replied to in <20180724182908.GD27053@avx2> has
> >> reduced CC list and is not linked to the patch postings.
> >>
> >> On 07/24/2018 08:29 PM, Alexey Dobriyan wrote:
> >>> On Mon, Jul 23, 2018 at 04:55:48PM -0700, akpm@linux-foundation.org wrote:
> >>>> The patch titled
> >>>>      Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
> >>>> has been added to the -mm tree.  Its filename is
> >>>>      mm-proc-pid-smaps_rollup-convert-to-single-value-seq_file.patch
> >>>
> >>>> Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
> >>>>
> >>>> The /proc/pid/smaps_rollup file is currently implemented via the
> >>>> m_start/m_next/m_stop seq_file iterators shared with the other maps files,
> >>>> that iterate over vma's.  However, the rollup file doesn't print anything
> >>>> for each vma, only accumulate the stats.
> >>>
> >>> What I don't understand why keep seq_ops then and not do all the work in
> >>> ->show hook.  Currently /proc/*/smaps_rollup is at ~500 bytes so with
> >>> minimum 1 page seq buffer, no buffer resizing is possible.
> >>
> >> Hmm IIUC seq_file also provides the buffer and handles feeding the data
> >> from there to the user process, which might have called read() with a smaller
> >> buffer than that. So I would rather not avoid the seq_file infrastructure.
> >> Or you're saying it could be converted to single_open()? Maybe, with more work.
> > 
> > Prefereably yes.
> 
> OK here it is. Sending as a new patch instead of delta, as that's easier
> to review - the delta is significant. Line stats wise it's the same.
> Again a bit less boilerplate thans to no special seq_ops, a bit more
> copy/paste in the open and release functions. But I guess it's better
> overall.
> 
> ----8>----
> From c6a2eaf3bb3546509d6b7c42f8bcc56cd7e92f90 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 18 Jul 2018 13:14:30 +0200
> Subject: [PATCH] mm: proc/pid/smaps_rollup: convert to single value seq_file

Reviewed-by: Alexey Dobriyan <adobriyan@gmail.com>
