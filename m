Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8C66B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:49:06 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id r5so7699788qcx.27
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:49:06 -0800 (PST)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id s67si17318316qgs.4.2014.11.24.13.49.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:49:04 -0800 (PST)
Received: by mail-qc0-f175.google.com with SMTP id b13so8462225qcw.34
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:49:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141123093348.GA16954@cucumber.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au> <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au> <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au> <20141123093348.GA16954@cucumber.anchor.net.au>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Tue, 25 Nov 2014 01:48:42 +0400
Message-ID: <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Sun, Nov 23, 2014 at 12:33 PM, Christian Marie <christian@ponies.io> wrote:
> Here's an update:
>
> Tried running 3.18.0-rc5 over the weekend to no avail. A load spike through
> Ceph brings no perceived improvement over the chassis running 3.10 kernels.
>
> Here is a graph of *system* cpu time (not user), note that 3.18 was a005.block:
>
> http://ponies.io/raw/cluster.png
>
> It is perhaps faring a little better that those chassis running the 3.10 in
> that it did not have min_free_kbytes raised to 2GB as the others did, instead
> it was sitting around 90MB.
>
> The perf recording did look a little different. Not sure if this was just the
> luck of the draw in how the fractal rendering works:
>
> http://ponies.io/raw/perf-3.10.png
>
> Any pointers on how we can track this down? There's at least three of us
> following at this now so we should have plenty of area to test.


Checked against 3.16 (3.17 hanged for an unrelated problem), the issue
is presented for single- and two-headed systems as well. Ceph-users
reported presence of the problem for 3.17, so probably we are facing
generic compaction issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
