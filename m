Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id AE1066B0062
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:04:16 -0400 (EDT)
Message-ID: <5192523B.7030805@parallels.com>
Date: Tue, 14 May 2013 19:03:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] return value from shrinkers
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
In-Reply-To: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

On 05/13/2013 06:16 PM, Oskar Andero wrote:
> Hi,
> 
> In a previous discussion on lkml it was noted that the shrinkers use the
> magic value "-1" to signal that something went wrong.
> 
> This patch-set implements the suggestion of instead using errno.h values
> to return something more meaningful.
> 
> The first patch simply changes the check from -1 to any negative value and
> updates the comment accordingly.
> 
> The second patch updates the shrinkers to return an errno.h value instead
> of -1. Since this one spans over many different areas I need input on what is
> a meaningful return value. Right now I used -EBUSY on everything for consitency.
> 
> What do you say? Is this a good idea or does it make no sense at all?
> 
> Thanks!
> 

Right now me and Dave are completely reworking the way shrinkers
operate. I suggest, first of all, that you take a look at that cautiously.

On the specifics of what you are doing here, what would be the benefit
of returning something other than -1 ? Is there anything we would do
differently for a return value lesser than 1?

So far, shrink_slab behaves the same, you are just expanding the test.
If you really want to push this through, I would suggest coming up with
a more concrete reason for why this is wanted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
