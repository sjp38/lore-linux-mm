Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E69C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:38:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A1F82087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:38:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A1F82087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B87C8E0003; Tue, 12 Mar 2019 00:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8676E8E0002; Tue, 12 Mar 2019 00:37:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 756AC8E0003; Tue, 12 Mar 2019 00:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35E248E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:37:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so248982pfn.11
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:37:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JtUAIwm+fw+csVs7MHFvkAh2WNHEPz2Riwp2JaCI7+o=;
        b=UmXpxHy5cTFUrUCgA8rZQ5RdP42ChcsvE/Ilsg85mHiv8DrOXJFKApW2wwq+YhrYbK
         gsM419fltpP/hVDbzwOdpPoefadUXxRxjsJK2jY9+fXn7Yl8Z9TVt5yfNhIv6qQ2+AY/
         7CPCF6KaitT57VorKr6CwRsrhBnAN0C3VW8D8y3esrNYjrmIQjOXGKfpyy0qUoDKKZjl
         fWFRrebnHs0RjEuFLAdGA0COkaGtlE4V/y0ozDos21zdpcOnAZcQht5y/YXJqCQdObVk
         /NJ3xQIrzUgrzQqMY7q8ZIB13N+e6+1aJbwVFvIlo0PdkIuoI+iViMzOSdU7PvBW+pMa
         VrdQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAU7QrgrjUkdOpPv3gYtABuA1QgEktWr+ku6b7u40Q6At19aIimd
	1iKWuEc2g2HAveZGA7QT2mWb+C5kyL77fkTRw7Y82nXC1J/+Nh7mdy885iFb0YdPyDrQinOfYYa
	OVNXpxeNApSSKH07PlBBPSwRwnu7MhTwQsh6BHHA7YoV1sdvYyXB6S+qgKwpKMjw=
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr36796387pfi.201.1552365478872;
        Mon, 11 Mar 2019 21:37:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdjTn43S1DpUXDjz8k0AnQm4xMjOydR4INB1pFSp3v9ythUjVaHpKg1LQ9sDKC7HQhUCZr
X-Received: by 2002:a62:ee0e:: with SMTP id e14mr36796329pfi.201.1552365477902;
        Mon, 11 Mar 2019 21:37:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552365477; cv=none;
        d=google.com; s=arc-20160816;
        b=i5mr/Nzh8j4go2jNj8R6g7i2IlIIXmIXzjuFzZ9CJzvgoHRBaS0yKqxN10Nx0WJPAE
         njn4uy6MWnwqHpxW5fwuqeno4Ml50a4tkKMwY/zjbT8bKxYP2vg8qQSSkLZ3b5Ao6GRj
         /6+1d93PWjYe4JvDc7p4//1NMcP2Ik/+EyjhvAsA5kP6Gtr+Y5RQBQo5NyCpKb/6vY/G
         cz9MOkdF47UBkoO8namxmVgPEUPUcqPNeiFr3bkDPyOrUwtusWH+nFZtzWPEaxZIxXBq
         2OuZdOspZ5C112YBPo3jjfQZmeke0a3cDzCVbFjJ3RaHOc1CzSaaz4gXZyuVt8VNpoZp
         RAiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JtUAIwm+fw+csVs7MHFvkAh2WNHEPz2Riwp2JaCI7+o=;
        b=fWK5xFKUN2mvzAtoUJWr6uaeMoZye9U25lq3OrK8T9gbymMxSXmeYbicok2q/7cV4m
         Ouo4bd42q5P5FMe+UHVT97leGEVSdOARPe+yoTwoGnDBWfO7qdVSsUEJBdYxLKhjLz95
         vfBqiRi1vU9oxgTF0XgNuo170HintM6MnbUWivwY/2atP1ShqwIRv+00DY3fKbahPb/F
         o+5yEE/Nl/l/5vXkaa02IB5FHzZuKboAAGD1b7tV63RnqykH6sJ0f8KRPD6lm4/UZZ/W
         trtW93UFJuBp/zEDN5k5BlUoR3u3hGkV2KOUf31Jeht+bkxFldqaXTNKYL3rvlKUYWXE
         YB7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id q3si6764469pfh.235.2019.03.11.21.37.56
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 21:37:57 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.143;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl6.internode.on.net with ESMTP; 12 Mar 2019 15:07:57 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h3ZAo-0000Tt-Fr; Tue, 12 Mar 2019 15:37:54 +1100
Date: Tue, 12 Mar 2019 15:37:54 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	"Barror, Robert" <robert.barror@intel.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Message-ID: <20190312043754.GD23020@dastard>
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org>
 <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > Hi Willy,
> > >
> > > We're seeing a case where RocksDB hangs and becomes defunct when
> > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > > handlers to XArray".
> > >
> > > I see some direct usage of xa_index and wonder if there are some more
> > > pmd fixups to do?
> > >
> > > Other thoughts?
> >
> > I don't see why killing a process would have much to do with PMD
> > misalignment.  The symptoms (hanging on a signal) smell much more like
> > leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> > get /proc/$pid/stack for a hung task?
> 
> It's fairly easy to reproduce, I'll see if I can package up all the
> dependencies into something that fails in a VM.
> 
> It's limited to xfs, no failure on ext4 to date.
> 
> The hung process appears to be:
> 
>      kworker/53:1-xfs-sync/pmem0

That's completely internal to XFS. Every 30s the work is triggered
and it either does a log flush (if the fs is active) or it syncs the
superblock to clean the log and idle the filesystem. It has nothing
to do with user processes, and I don't see why killing a process has
any effect on what it does...

> ...and then the rest of the database processes grind to a halt from there.
> 
> Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:
> 
> [<0>] worker_thread+0xb2/0x380
> [<0>] kthread+0x112/0x130
> [<0>] ret_from_fork+0x1f/0x40
> [<0>] 0xffffffffffffffff

Much more useful would be:

# echo w > /proc/sysrq-trigger

And post the entire output of dmesg.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

