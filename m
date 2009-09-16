Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 70BEC6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 23:46:49 -0400 (EDT)
Received: by qyk16 with SMTP id 16so1294248qyk.20
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:46:54 -0700 (PDT)
Date: Tue, 15 Sep 2009 20:46:50 -0700
From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: 2.6.32 -mm merge plans
Message-ID: <20090916034650.GD2756@core.coreip.homeip.net>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Tue, Sep 15, 2009 at 04:15:35PM -0700, Andrew Morton wrote:
> 
> input-touchpad-not-detected-on-asus-g1s.patch

This one has been in mainline for a while now, please drop.

> input-add-a-shutdown-method-to-pnp-drivers.patch

This should go through PNP tree (do we have one?).

-- 
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
