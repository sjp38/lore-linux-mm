Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D2F0A6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:12:20 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so5147426pab.18
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 18:12:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gw10si17826870pac.240.2014.09.22.18.12.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 18:12:19 -0700 (PDT)
Date: Mon, 22 Sep 2014 18:12:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
Message-Id: <20140922181217.bb56b74d.akpm@linux-foundation.org>
In-Reply-To: <20140923103925.08b35d84@canb.auug.org.au>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
	<20140923103925.08b35d84@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz

On Tue, 23 Sep 2014 10:39:25 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is to
> > be applied.
> 
> This tar file is no longer expanded into a broken-out directory?

ssh connections to ozlabs.org were intermittently timing out,
producing a partial result.  Then they stopped altogether while I was
poking at it.

Maybe it will be feeling better tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
