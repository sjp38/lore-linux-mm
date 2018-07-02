Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD8306B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 10:06:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so9955902pld.23
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 07:06:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y6-v6si14069657pgy.224.2018.07.02.07.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Jul 2018 07:06:14 -0700 (PDT)
Date: Mon, 2 Jul 2018 07:06:12 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] x86: make Memory Management options more visible
Message-ID: <20180702140612.GA7333@infradead.org>
References: <af12c83d-2533-ae00-b53c-1fc1a9d8e9ce@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af12c83d-2533-ae00-b53c-1fc1a9d8e9ce@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sun, Jul 01, 2018 at 07:48:38PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Currently for x86, the "Memory Management" kconfig options are
> displayed under "Processor type and features."  This tends to
> make them hidden or difficult to find.
> 
> This patch makes Memory Managment options a first-class menu by moving
> it away from "Processor type and features" and into the main menu.
> 
> Also clarify "endmenu" lines with '#' comments of their respective
> menu names, just to help people who are reading or editing the
> Kconfig file.
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Hmm, can you take off from this for now and/or rebase it on top of
this series:

	http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/kconfig-cleanups
