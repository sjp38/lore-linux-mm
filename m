Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3E5DF6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:03:16 -0400 (EDT)
Date: Fri, 23 Aug 2013 13:03:10 +0200
From: Karel Zak <kzak@redhat.com>
Subject: Re: [PATCH 02/02] swapon: allow a more flexible swap discard policy
Message-ID: <20130823110310.GA2352@x2.net.home>
References: <cover.1369529143.git.aquini@redhat.com>
 <6346c223ca2acb30b35480b9d51638466aac5fe6.1369530033.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6346c223ca2acb30b35480b9d51638466aac5fe6.1369530033.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, jmoyer@redhat.com, kosaki.motohiro@gmail.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

On Sun, May 26, 2013 at 01:31:56AM -0300, Rafael Aquini wrote:
>  sys-utils/swapon.8 | 24 +++++++++++++------
>  sys-utils/swapon.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 77 insertions(+), 17 deletions(-)

 Applied, thanks.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
