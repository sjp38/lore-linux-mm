Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C8E126B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:47:20 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so575133ywm.26
        for <linux-mm@kvack.org>; Wed, 29 Apr 2009 00:48:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090429130430.4B11.A69D9226@jp.fujitsu.com>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu>
	 <20090429130430.4B11.A69D9226@jp.fujitsu.com>
Date: Wed, 29 Apr 2009 16:48:05 +0900
Message-ID: <2f11576a0904290048m5a33e8a8j76c9a7ae067f8c83@mail.gmail.com>
Subject: Re: Swappiness vs. mmap() and interactive response
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

one mistake

> mouse move lag: =A0 =A0 =A0 =A0 =A0 =A0 =A0 not happend
> window move lag: =A0 =A0 =A0 =A0 =A0 =A0 =A0not happend
> Mapped page decrease rapidly: not happend (I guess, these page stay in
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0active list on my system)
> page fault large latency: =A0 =A0 happend (latencytop display >200ms)

             ^^^^^^^^^

            >1200ms

sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
