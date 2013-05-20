Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0E50F6B0033
	for <linux-mm@kvack.org>; Mon, 20 May 2013 09:56:16 -0400 (EDT)
Date: Mon, 20 May 2013 06:56:35 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: vmscan: add BUG_ON on illegal return values from
 scan_objects
Message-ID: <20130520135635.GA18693@kroah.com>
References: <1369041267-26424-1-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369041267-26424-1-git-send-email-oskar.andero@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Mon, May 20, 2013 at 11:14:27AM +0200, Oskar Andero wrote:
> Add a BUG_ON to catch any illegal value from the shrinkers. This fixes a
> potential bug if scan_objects returns a negative other than -1, which
> would lead to undefined behaviour.

So it's better to crash a machine and keep anyone from using it?
Instead of recovering from an error you found?  Not good.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
