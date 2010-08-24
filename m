Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 269E66B0358
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 22:05:10 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o7O251Vp027166
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:05:01 -0700
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by kpbe14.cbf.corp.google.com with ESMTP id o7O24xnP014413
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:04:59 -0700
Received: by gxk1 with SMTP id 1so2668244gxk.12
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:04:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100824020136.GA9536@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-5-git-send-email-mrubin@google.com> <20100824020136.GA9536@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 19:04:39 -0700
Message-ID: <AANLkTim8cDKnBSgJs=_FwXj1SrjQ5PhyrT4HjbXAmytw@mail.gmail.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 7:01 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
>> + =A0 =A0 global_dirty_limits(v + NR_DIRTY_THRESHOLD, v + NR_DIRTY_BG_TH=
RESHOLD);
>
> Sorry I messed it up. The parameters should be swapped.

Got it. Thanks.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
