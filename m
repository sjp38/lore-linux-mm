Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5C48E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 02:32:46 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so37458463edb.5
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 23:32:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u19-v6si2500361ejm.190.2019.01.06.23.32.44
        for <linux-mm@kvack.org>;
        Sun, 06 Jan 2019 23:32:44 -0800 (PST)
Subject: Re: mmotm 2018-12-21-15-28 uploaded
References: <20181221232853.WLvEi%akpm@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <99ab6512-9fce-9cb9-76e7-7f83d87d5f86@arm.com>
Date: Mon, 7 Jan 2019 13:02:31 +0530
MIME-Version: 1.0
In-Reply-To: <20181221232853.WLvEi%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org



On 12/22/2018 04:58 AM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-12-21-15-28 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
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
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.gi

Hello Michal,

I dont see the newer tags on this tree. Tried fetching all the tags from the tree
but only see these right now for 2018. This release should have an equivalent tag
(mmotm-2018-12-21-15-28) right ? 

mmotm-2018-01-04-16-19
mmotm-2018-01-12-16-53
mmotm-2018-01-18-16-31
mmotm-2018-01-25-16-20
mmotm-2018-01-31-16-51
mmotm-2018-02-06-16-41
mmotm-2018-02-21-14-48
mmotm-2018-03-13-15-15
mmotm-2018-03-14-16-24
mmotm-2018-03-22-16-18
mmotm-2018-03-28-16-05
mmotm-2018-04-05-16-59
mmotm-2018-04-10-17-02
mmotm-2018-04-13-17-28
mmotm-2018-05-03-15-54
mmotm-2018-05-10-16-34
mmotm-2018-05-18-16-44
mmotm-2018-05-25-14-52

- Anshuman
