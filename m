Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 87A356B0082
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 13:58:41 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id z2so1801795wiv.0
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 10:58:41 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id h8si5500345wiw.78.2014.04.16.10.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 10:58:40 -0700 (PDT)
Date: Wed, 16 Apr 2014 18:58:37 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Kernel crash triggered by dd to file with memcg, worst on btrfs
Message-ID: <20140416175837.GA9412@alpha.arachsys.com>
References: <20140416174210.GA11486@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416174210.GA11486@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

Richard Davies wrote:
> I have a test case in which I can often crash an entire machine by running
> dd to a file with a memcg with relatively generous limits. This is
> simplified from real world problems with heavy disk i/o inside containers.
>
> The crashes are easy to trigger when dding to create a file on btrfs. On
> ext3, typically there is just an error in the kernel log, although
> occasionally it also crashes.

A further note - the ext3 SLUB errors occur when dding into a ext3 file
alone. The few ext3 crashes occurred when dding into a btrfs file for a
while without a crash, then switching to dding into an ext3 file. So the
"ext3 crashes" could actually be due to btrfs cached data still in memory -
i.e. all crashes could be due to btrfs use.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
