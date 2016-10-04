Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 984D16B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 13:32:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so132286655wmg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 10:32:20 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id gd1si5812877wjb.55.2016.10.04.10.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 10:32:19 -0700 (PDT)
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de>
 <20161004084136.GD17515@quack2.suse.cz>
 <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de>
From: Johannes Bauer <dfnsonfsduifb@gmx.de>
Message-ID: <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
Date: Tue, 4 Oct 2016 19:32:14 +0200
MIME-Version: 1.0
In-Reply-To: <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On 04.10.2016 18:50, Johannes Bauer wrote:

> Uhh, that sounds painful. So I'm following Ted's advice and building
> myself a 4.8 as we speak.

Damn bad idea to build on the instable target. Lots of gcc segfaults and
weird stuff, even without a kernel panic. The system appears to be
instable as hell. Wonder how it can even run and how much of the root fs
is already corrupted :-(

Rebuilding 4.8 on a different host.

Cheers,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
