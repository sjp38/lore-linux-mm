Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 4C3A66B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:44:52 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so1077593pbc.35
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 08:44:51 -0700 (PDT)
Date: Fri, 28 Jun 2013 00:44:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130627154423.GB5006@gmail.com>
References: <20130626231712.4a7392a7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130626231712.4a7392a7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, anton@enomsg.org, akpm@linux-foundation.org, kmpark@infradead.org, hyunhee.kim@samsung.com

On Wed, Jun 26, 2013 at 11:17:12PM -0400, Luiz Capitulino wrote:
> Currently, an eventfd is notified for the level it's registered for
> _plus_ higher levels.
> 
> This is a problem if an application wants to implement different
> actions for different levels. For example, an application might want
> to release 10% of its cache on level low, 50% on medium and 100% on
> critical. To do this, an application has to register a different
> eventfd for each pressure level. However, fd low is always going to
> be notified and and all fds are going to be notified on level critical.
> 
> Strict mode solves this problem by strictly notifiying an eventfd
> for the pressure level it registered for. This new mode is optional,
> by default we still notify eventfds on higher levels too.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
Acked-by: Minchan Kim <minchan@kernel.org>

If you will update this patch without major big change, you can keep
earlier Acked-by and Reviewe-by.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
