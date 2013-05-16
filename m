Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id BDAB36B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 07:52:22 -0400 (EDT)
Date: Thu, 16 May 2013 21:52:12 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH] mm: vmscan: handle any negative return value from
 scan_objects
Message-ID: <20130516115212.GC11167@devil.localdomain>
References: <1368693736-15486-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368693736-15486-1-git-send-email-oskar.andero@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, May 16, 2013 at 10:42:16AM +0200, Oskar Andero wrote:
> The shrinkers must return -1 to indicate that it is busy. Instead, treat
> any negative value as busy.

Why? The API defines return condition for aborting a scan and gives
a specific value for doing that. i.e. explain why should change the
API to over-specify the 'abort scan" return value like this.

FWIW, using "any" negative number for "abort scan" is a bad API
design decision. It means that in future we can't introduce
different negative return values in the API if we have a new to.
i.e. each specific negative return value needs to have the potential
for defining a different behaviour. 

So if any change needs to be made, it is to change the -1 return
value to an enum and have the shrinkers return that enum when they
want an abort.

-Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
