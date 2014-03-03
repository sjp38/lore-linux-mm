Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 245D26B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 15:57:46 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id x3so2137195qcv.25
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 12:57:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g16si6694100qgd.65.2014.03.03.12.57.45
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 12:57:45 -0800 (PST)
Message-ID: <5314D57C.6070608@redhat.com>
Date: Mon, 03 Mar 2014 14:18:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: scan_unevictable_pages issue
References: <E04081535648644687C2E921D23610432E488F@VRSKUTMB1.veriskdom.com>
In-Reply-To: <E04081535648644687C2E921D23610432E488F@VRSKUTMB1.veriskdom.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sugat Sikrikar <ssikrikar@veriskhealth.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/28/2014 12:19 AM, Sugat Sikrikar wrote:
> Hello ,
>
> Following message is causing our server to halt. Please, suggest.

I suspect something else is causing your problems.

> "Feb 27 13:54:03 MWG kernel: [18464.328680] The scan_unevictable_pages
> sysctl/node-interface has been disabled for lack of a legitimate use
> case.  If you have one, please send an email to linux-mm@kvack.org
> <mailto:linux-mm@kvack.org>."

Writing to /proc/sys/vm/scan_unevictable_pages causes
that warning to be printed exactly once, after which
the system should continue running the way it did
before.

As an aside, do you have a legitimate use case for
scan_unevictable_pages? :)

It would be good to get more information on what happens
when your system is about to hang (or hanging).

What version are you running?

Do you see lots of unevictable pages?

What about active/inactive anon/file pages?

What about free memory?

What about slab?  Page tables?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
