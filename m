Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C2AF76B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 16:52:43 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so670472wah.22
        for <linux-mm@kvack.org>; Fri, 03 Apr 2009 13:53:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090331153223.74b177bd@skybase>
References: <20090331153223.74b177bd@skybase>
Date: Fri, 3 Apr 2009 13:53:24 -0700
Message-ID: <6934efce0904031353x3323e2c3g87723c1881e95c1c@mail.gmail.com>
Subject: Re: [PATCH] do_xip_mapping_read: fix length calculation
From: Jared Hulbert <jaredeh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Carsten Otte <cotte@de.ibm.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> This bug is the cause for the heap corruption Carsten has been chasing
> for so long:

Finally saw this issue on ARM.  Some programs in Android on ARM were
crashing with AXFS.  This fixed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
