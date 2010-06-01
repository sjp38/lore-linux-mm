Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEBF6B01D6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:52:20 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o51KqIjl023515
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:52:18 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz9.hot.corp.google.com with ESMTP id o51KqHba029818
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:52:17 -0700
Received: by pzk33 with SMTP id 33so2589100pzk.17
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:52:17 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:52:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006011351400.13136@chino.kir.corp.google.com>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com> <AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com> <AANLkTilmr29Vv3N64n7KVj9fSDpfBHIt8-quxtEwY0_X@mail.gmail.com> <alpine.LSU.2.00.1005211410170.14789@sister.anvils>
 <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 27 May 2010, dave b wrote:

> That was just a simple test case with dd. That test case might be
> invalid - but it is trying to trigger out of memory - doing this any
> other way still causes the problem. I note that playing with some bios
> settings I was actually able to trigger what appeared to be graphics
> corruption issues when I launched kde applications ... nothing shows
> up in dmesg so this might just be a conflict between xorg and the
> kernel with those bios settings...
> 
> Anyway, This is no longer a 'problem' for me since I disabled
> overcommit and altered the values for dirty_ratio and
> dirty_background_ratio - and I cannot trigger it.
> 

Disabling overcommit should always do it, but I'd be interested to know if 
restoring dirty_ratio to 40 would help your usecase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
