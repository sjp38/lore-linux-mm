Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id C83426B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 18:02:32 -0400 (EDT)
Date: Thu, 27 Jun 2013 15:02:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-Id: <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
In-Reply-To: <20130626231712.4a7392a7@redhat.com>
References: <20130626231712.4a7392a7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, anton@enomsg.org, kmpark@infradead.org, hyunhee.kim@samsung.com

On Wed, 26 Jun 2013 23:17:12 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:

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

It didn't take long for this simple interface to start getting ugly :(
And having the fd operate in different modes is ugly.

Can we instead pass the level in the event payload?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
