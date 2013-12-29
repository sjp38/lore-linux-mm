Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 13ADB6B0031
	for <linux-mm@kvack.org>; Sun, 29 Dec 2013 15:26:28 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so4870361eae.27
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 12:26:28 -0800 (PST)
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
        by mx.google.com with ESMTPS id s42si49212957eew.224.2013.12.29.12.26.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Dec 2013 12:26:28 -0800 (PST)
Received: by mail-ea0-f169.google.com with SMTP id l9so4177731eaj.14
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 12:25:53 -0800 (PST)
Message-ID: <52C0854D.2090802@googlemail.com>
Date: Sun, 29 Dec 2013 21:25:49 +0100
From: Stefan Beller <stefanbeller@googlemail.com>
MIME-Version: 1.0
Subject: Re: Help about calculating total memory consumption during booting
References: <1388341026.52582.YahooMailNeo@web160105.mail.bf1.yahoo.com>
In-Reply-To: <1388341026.52582.YahooMailNeo@web160105.mail.bf1.yahoo.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On 29.12.2013 19:17, PINTU KUMAR wrote:
> Hi,
> 
> I need help in roughly calculating the total memory consumption in an embedded Linux system just after booting is finished.
> I know, I can see the memory stats using "free" and "/proc/meminfo"
> 
> But, I need the breakup of "Used" memory during bootup, for both kernel space and user application.
> 
> Example, on my ARM machine with 128MB RAM, the free memory reported is roughly:
> Total: 90MB
> Used: 88MB
> Free: 2MB
> Buffer+Cached: (5+19)MB
> 
> Now, my question is, how to find the breakup of this "Used" memory of "88MB".
> This should include both kernel space allocation and user application allocation(including daemons).
> 

http://www.linuxatemyram.com/ dont panic ;)

How about htop, top or
"valgrind --tool massif"




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
