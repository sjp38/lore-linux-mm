Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1FE6B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:26:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u5so640600lfg.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:26:46 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id x18si2684846ljb.445.2017.11.03.02.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 02:26:45 -0700 (PDT)
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
References: <20171101053244.5218-1-slandden@gmail.com>
 <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
 <1509549749.2563336.1158179384.52E1E4B4@webmail.messagingengine.com>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <2cc07a12-9cf4-429b-11d3-269c486879e3@sonymobile.com>
Date: Fri, 3 Nov 2017 10:22:49 +0100
MIME-Version: 1.0
In-Reply-To: <1509549749.2563336.1158179384.52E1E4B4@webmail.messagingengine.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>, Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 11/01/2017 04:22 PM, Colin Walters wrote:
>
> On Wed, Nov 1, 2017, at 11:16 AM, Colin Walters wrote:
>> as the maintainer of glib2 which is used by a *lot* of things; I'm not
> (I meant to say "a" maintainer)
>
> Also, while I'm not an expert in Android, I think the "what to kill" logic
> there lives in userspace, right?   So it feels like we should expose this
> state in e.g. /proc and allow userspace daemons (e.g. systemd, kubelet) to perform
> idle collection too, even if the system isn't actually low on resources
> from the kernel's perspective.
>
> And doing that requires some sort of kill(pid, SIGKILL_IF_IDLE) or so?
>
You are right, in android it is the activity manager that performs this tasks. And if services
dies without talking to the activity manager the service is restarted, unless it is
on highest oom score. A other problem is that a lot communication in android is binder not epoll.

And a signal that can not be caught not that good. But a "warn" signal of the userspace choice in
something in a context similar to ulimit. SIGXFSZ/SIGXCPU that you can pickup and notify activity manager might work.

However, in android this is already solved with OnTrimMemory that is message sent from activitymanager to
application, services etc when system need memory back.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
