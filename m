Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 933506B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:52:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t18so5013145oih.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:52:08 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id d82si1277394oia.60.2017.08.11.14.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:52:07 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id j32so24602522iod.0
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:52:07 -0700 (PDT)
Date: Fri, 11 Aug 2017 15:52:05 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
Message-ID: <20170811215205.x7e3zhx2mkseg7jy@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
 <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
 <20170811211302.limmjv4rmq23b25b@smitten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811211302.limmjv4rmq23b25b@smitten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Fri, Aug 11, 2017 at 03:13:02PM -0600, Tycho Andersen wrote:
> You're suggesting something like this instead? Seems to work fine.

And in fact, using this patch instead means that booting on 4k pages
works too... I guess because NO_BLOCK_MAPPINGS is looked at in a few
other places that matter too? Anyway, I'll use this patch instead,
thanks for the suggestion!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
