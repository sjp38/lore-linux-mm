Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F41B6B0287
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:22:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n82so2789650oig.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:22:31 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id j29si577692otd.180.2017.11.01.08.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 08:22:30 -0700 (PDT)
Message-Id: <1509549749.2563336.1158179384.52E1E4B4@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <20171101053244.5218-1-slandden@gmail.com>
 <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
Date: Wed, 01 Nov 2017 11:22:29 -0400
In-Reply-To: <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes process
 to death row (new syscall)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org



On Wed, Nov 1, 2017, at 11:16 AM, Colin Walters wrote:
>
> as the maintainer of glib2 which is used by a *lot* of things; I'm not

(I meant to say "a" maintainer)

Also, while I'm not an expert in Android, I think the "what to kill" logic
there lives in userspace, right?   So it feels like we should expose this
state in e.g. /proc and allow userspace daemons (e.g. systemd, kubelet) to perform
idle collection too, even if the system isn't actually low on resources
from the kernel's perspective.

And doing that requires some sort of kill(pid, SIGKILL_IF_IDLE) or so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
