Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1227C6B0268
	for <linux-mm@kvack.org>; Sun, 30 Oct 2016 14:16:02 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 34so21443825uac.6
        for <linux-mm@kvack.org>; Sun, 30 Oct 2016 11:16:02 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id r10si10028679uab.204.2016.10.30.11.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Oct 2016 11:16:00 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id d65so1790335vkg.0
        for <linux-mm@kvack.org>; Sun, 30 Oct 2016 11:16:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5812a9b6.OlAMBhewokz9/Mou%akpm@linux-foundation.org>
References: <5812a9b6.OlAMBhewokz9/Mou%akpm@linux-foundation.org>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 30 Oct 2016 14:15:30 -0400
Message-ID: <CAP=VYLqNv8p_ojkcjeWCN-nMumDg296UkV1b460KDHAXOHZSEA@mail.gmail.com>
Subject: Re: mmotm 2016-10-27-18-27 uploaded
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.cz>, broonie@kernel.org

On Thu, Oct 27, 2016 at 9:28 PM,  <akpm@linux-foundation.org> wrote:
> The mm-of-the-moment snapshot 2016-10-27-18-27 has been uploaded to
>
>    http://www.ozlabs.org/~akpm/mmotm/

Just a heads up:

Somehow one of the akpm commits as it appears in linux-next has had
spaces replaced with garbage chars:

https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/scripts/get_maintainer.pl?id=b67071653d3fc9f9b73aab3e7978f060728bf392

Paul.
--

>
> mmotm-readme.txt says
>
> README for mm-of-the-moment:
>
> http://www.ozlabs.org/~akpm/mmotm/
>
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
>
> You will need quilt to apply these patches to the latest Linus release (4.x
> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
>
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.
>
> This tree is partially included in linux-next.  To see which patches are
> included in linux-next, consult the `series' file.  Only the patches
> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> linux-next.
>
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the
> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> file, http://www.ozlabs.org/~akpm/mmotm/series.
>
>
> A full copy of the full kernel tree with the linux-next and mmotm patches
> already applied is available through git within an hour of the mmotm
> release.  Individual mmotm releases are tagged.  The master branch always
> points to the latest release, so it's constantly rebasing.
>
> http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/
>
[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
