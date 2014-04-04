Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFE36B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 02:54:12 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id m20so3018404qcx.24
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 23:54:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id di5si3140225qcb.20.2014.04.03.23.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 23:54:09 -0700 (PDT)
Date: Thu, 3 Apr 2014 23:53:53 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
Message-ID: <20140404065353.GA22039@infradead.org>
References: <533B04A9.6090405@bbn.com>
 <20140402111032.GA27551@infradead.org>
 <1396439119.2726.29.camel@menhir>
 <533CA0F6.2070100@bbn.com>
 <CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com>
 <533DC357.1080203@bbn.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533DC357.1080203@bbn.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Hansen <rhansen@bbn.com>
Cc: mtk.manpages@gmail.com, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Troxel <gdt@ir.bbn.com>, Peter Zijlstra <peterz@infradead.org>

Guys, I don't really see why you get so worked up about this.  There is
lots and lots of precedent of Linux allowing non-Posix (or non-standard
in general) arguments to system calls.  Even ones that don't have
symbolic names defined for them (the magic 3 open argument for device
files).

Given that we historicaly allowed the 0 argument to msync we'll have to
keep supporting it to not break existing userspace, and adding warnings
triggered by userspace that the person running the system usually can't
fix for something that is entirely harmless at runtime isn't going to
win you friends either.

A "strictly Posix" environment that catches all this sounds fine to me,
but it's something that should in the userspace c runtime, not the
kernel.  The kernel has never been about strict Posix implementations,
it sometimes doesn't even make it easy to implement the semantics in
user land, which is a bit unfortunate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
