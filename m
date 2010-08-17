Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EACD6B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 12:25:29 -0400 (EDT)
Subject: Re: [PATCH] Export mlock information via smaps
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <201008171039.31070.knikanth@suse.de>
References: <201008171039.31070.knikanth@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Aug 2010 11:25:36 -0500
Message-ID: <1282062336.10679.226.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> Currently there is no way to find whether a process has locked its pages in
> memory or not. And which of the memory regions are locked in memory.
> 
> Add a new field to perms field 'l' to export this information. The information
> exported via maps file is not changed.

I'm worried that your new 'l' flag will fatally surprise some naive
parser of this file.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
