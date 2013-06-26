Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id F0F546B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 23:21:05 -0400 (EDT)
Date: Tue, 25 Jun 2013 23:20:27 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130625232027.7c3ed3de@redhat.com>
In-Reply-To: <CAOK=xRN-cNJZgPqWuapsPjeGqFm9RAEXVn6kN971aZ016ocxxA@mail.gmail.com>
References: <20130625175129.7c0d79e1@redhat.com>
	<CAH9JG2U6Kg9MBdFX-OnfrqGAsJGJwEMkg01-uUycF1r3VyZqrg@mail.gmail.com>
	<CAOK=xRN-cNJZgPqWuapsPjeGqFm9RAEXVn6kN971aZ016ocxxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org

On Wed, 26 Jun 2013 10:12:15 +0900
Hyunhee Kim <hyunhee.kim@samsung.com> wrote:

> Please see "[PATCH v3] memcg: event control at vmpressure". mail
> thread. (and also the thread I sent last Saturday.)
> There was discussion on this mode not sending lower events when "level
> != ev->level".

The new argument this patch adds should be orthogonal to what has been
discussed and suggested in that thread. The patches conflict though, but
it's just a matter of rebasing if both are ACKed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
