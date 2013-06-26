Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E6D996B0037
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 03:50:46 -0400 (EDT)
Date: Wed, 26 Jun 2013 16:50:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130626075051.GG29127@bbox>
References: <20130625175129.7c0d79e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130625175129.7c0d79e1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, anton@enomsg.org, akpm@linux-foundation.org

On Tue, Jun 25, 2013 at 05:51:29PM -0400, Luiz Capitulino wrote:
> Currently, applications are notified for the level they registered for
> _plus_ higher levels.
> 
> This is a problem if the application wants to implement different
> actions for different levels. For example, an application might want
> to release 10% of its cache on level low, 50% on medium and 100% on
> critical. To do this, the application has to register a different fd
> for each event. However, fd low is always going to be notified and
> and all fds are going to be notified on level critical.
> 
> Strict mode solves this problem by strictly notifiying the event
> an fd has registered for. It's optional. By default we still notify
> on higher levels.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Shouldn't we make this default?
What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
