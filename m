Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B0A6D6B0096
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 10:47:06 -0500 (EST)
Received: by bwz7 with SMTP id 7so1795671bwz.6
        for <linux-mm@kvack.org>; Sat, 30 Jan 2010 07:47:04 -0800 (PST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <201001170138.37283.rjw@sisk.pl>
References: <1263549544.3112.10.camel@maxim-laptop>
	 <1263678289.4276.4.camel@maxim-laptop> <201001162317.39940.rjw@sisk.pl>
	 <201001170138.37283.rjw@sisk.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Jan 2010 17:46:59 +0200
Message-ID: <1264866419.27933.0.camel@maxim-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-17 at 01:38 +0100, Rafael J. Wysocki wrote: 
> Hi,
> 
> I thing the snippet below is a good summary of what this is about.

Any progress on that?

Best regards,
Maxim Levitsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
