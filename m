Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 73E036B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:45:38 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:45:07 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628144507.37d28ed9@redhat.com>
In-Reply-To: <20130628170917.GA12610@teo>
References: <20130626231712.4a7392a7@redhat.com>
	<20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
	<20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, 28 Jun 2013 10:09:17 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> So, I would now argue that the current scheme is perfectly OK and can do
> everything you can do with the "strict" one,

I forgot commenting this bit. This is not true, because I don't want a
low fd to be notified on critical level. The current interface just
can't do that.

However, it *is* possible to make non-strict work on strict if we make
strict default _and_ make reads on memory.pressure_level return
available events. Just do this on app initialization:

for each event in memory.pressure_level; do
	/* register eventfd to be notified on "event" */
done

Then eventfd will always be notified, no matter the event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
