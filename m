Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 154246B0034
	for <linux-mm@kvack.org>; Wed, 15 May 2013 20:48:14 -0400 (EDT)
Date: Thu, 16 May 2013 10:47:49 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 1/2] mm: vmscan: let any negative return value from
 shrinker mean error
Message-ID: <20130516004749.GD24635@dastard>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
 <1368454595-5121-2-git-send-email-oskar.andero@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368454595-5121-2-git-send-email-oskar.andero@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>

On Mon, May 13, 2013 at 04:16:34PM +0200, Oskar Andero wrote:
> The shrinkers must return -1 to indicate that it is busy. Instead of
> relaying on magical numbers, let any negative value indicate error. This
> opens up for using the errno.h error codes in the shrinker
> implementations.

Just what is the shrinker infrastructure supposed to do with a
random error code?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
