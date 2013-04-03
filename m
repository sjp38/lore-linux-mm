Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 8EF1A6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 11:22:53 -0400 (EDT)
Date: Wed, 3 Apr 2013 16:22:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130403152249.GB4908@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402231613.GA4946@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130402231613.GA4946@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 02, 2013 at 07:16:13PM -0400, Theodore Ts'o wrote:
> I've tried doing some quick timing, and if it is a performance
> regression, it's not a recent one --- or I haven't been able to
> reproduce what Mel is seeing.  I tried the following commands while
> booted into 3.2, 3.8, and 3.9-rc3 kernels:
> 
> time git clone ...
> rm .git/index ; time git reset
> 

FWIW, I had run a number if git checkout based tests over time and none
of them revealed anything useful. Granted it was on other machines but I
don't think it's git on its own. It's a combination that leads to this
problem. Maybe it's really an IO scheduler problem and I need to figure
out what combination triggers it.

> <SNIP>
>
> Mel, how bad is various git commands that you are trying?  Have you
> tried using time to get estimates of how long a git clone or other git
> operation is taking?
> 

Unfortunately, the milage varies considerably and it's not always
possible to time the operation. It may be that one occasion that opening
a mail takes an abnormal length time with git operations occasionally
making it far worse.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
