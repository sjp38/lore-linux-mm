Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BBB326B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 16:35:59 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so60212473pdb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:35:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nn5si46687095pbc.21.2015.06.25.13.35.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 13:35:58 -0700 (PDT)
Date: Thu, 25 Jun 2015 13:35:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zswap: dynamic pool creation
Message-Id: <20150625133557.c519c933c104a2657417bd02@linux-foundation.org>
In-Reply-To: <CALZtONCHfcK4wUhQOiiXRL6D4fR92sKqZ+edctSZU3Xf0qWx_w@mail.gmail.com>
References: <1433419358-21820-1-git-send-email-ddstreet@ieee.org>
	<CALZtONC_-uQcE30hgzwD-V9Ps9k8g2Y_XUTjD9xcXaiXAc-hGw@mail.gmail.com>
	<CALZtONA6C3v0mwwgbf4QqLqehqtrdqs9Y=Td2-HXyhQhySki_w@mail.gmail.com>
	<CALZtOND9wWe_58PNW396dpUy_HBrr+pv5_-KNfUGjvrPiGV0Gw@mail.gmail.com>
	<CALZtONCHfcK4wUhQOiiXRL6D4fR92sKqZ+edctSZU3Xf0qWx_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, 25 Jun 2015 16:22:07 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Andrew (or anyone else) do you have any objection to this patch?  I
> assume Seth is on an extended vacation; maybe you could add this to
> your mmotm?  If Seth prefers changes to it he still has a couple
> months-ish until the next merge window.  I could then send the
> follow-on patches, that allow zswap params to be set at runtime.  I
> can resend them all as a series, if you prefer that.

I'll take a look once the merge window mayhem settles down.  But it
never hurts to do a refresh/retest/resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
