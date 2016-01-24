Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E10A96B0253
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 11:57:12 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id t15so21266116igr.0
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 08:57:12 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id c1si19540703igx.68.2016.01.24.08.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 08:57:12 -0800 (PST)
Received: by mail-ig0-x22f.google.com with SMTP id h5so17962733igh.0
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 08:57:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601221046020.17984@east.gentwo.org>
References: <569FAC90.5030407@oracle.com>
	<alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
	<20160120212806.GA26965@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
	<20160121082402.GA29520@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
	<20160121165148.GF29520@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
	<20160122140418.GB19465@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601220950290.17929@east.gentwo.org>
	<20160122161201.GC19465@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601221046020.17984@east.gentwo.org>
Date: Sun, 24 Jan 2016 08:57:11 -0800
Message-ID: <CA+55aFwHzFMoZzXypH4t_3kgn3=mihP9ViNHQOu-e2jrTro65A@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 22, 2016 at 8:46 AM, Christoph Lameter <cl@linux.com> wrote:
>
> Subject: vmstat: Remove BUG_ON from vmstat_update
>
> If we detect that there is nothing to do just set the flag and do not check
> if it was already set before. [..]

Ok, I am assuming this is in Andrew's queue already, but this bug hit
my machine overnight, so I'm applying it directly..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
