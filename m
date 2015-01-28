Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 622276B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:27:15 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id n8so16312212qaq.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:27:15 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id o9si6182607qaa.43.2015.01.28.06.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 06:27:14 -0800 (PST)
Received: by mail-qg0-f48.google.com with SMTP id z60so16789812qgd.7
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:27:14 -0800 (PST)
Message-ID: <54C8F1C1.7050908@gmail.com>
Date: Wed, 28 Jan 2015 09:27:13 -0500
From: John Moser <john.r.moser@gmail.com>
MIME-Version: 1.0
Subject: Re: OOM at low page cache?
References: <54C2C89C.8080002@gmail.com> <54C77086.7090505@suse.cz> <20150128062609.GA4706@blaptop>
In-Reply-To: <20150128062609.GA4706@blaptop>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

On 01/28/2015 01:26 AM, Minchan Kim wrote:
>
> Below could be band-aid until we find a elegant solution?
>
>

I don't know about elegant; but I'd be impressed if anyone figured out
how to just go Windows 95 with it and build a Task Master interface.  It
would be useful to have a kernel interface that allows a service to
attach, delegate an interface program, etc., and then pull it up under
certain conditions (low memory, heavy scheduling due to lots of
fork()ing, etc.) and assign temporary high priority.  Basically,
nearly-pause the system and allow the user to select and kill/term
processes, or bring a process forward (for like 10 seconds, then kick it
back again) so the user can save their work and exit gracefully.  At
hard OOM, you could either OOM or pause everything (you'd need a
zero-allocation path to kill things in a user-end OOM handler).

Yeah, imaginative fantasies.  Totally doable, but probably too complex
to bother.  There's all kinds of semaphore inversion or some such to
worry about; how do you ensure an X11 program is 100% snappy when the
system is being thrashed by fork() bombs and memory pressure?

Actually, I have no idea what I'm talking about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
