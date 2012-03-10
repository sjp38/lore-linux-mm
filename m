Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 679986B0044
	for <linux-mm@kvack.org>; Sat, 10 Mar 2012 01:25:59 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1828452ghr.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 22:25:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
Date: Fri, 9 Mar 2012 22:25:58 -0800
Message-ID: <CABCjUKBZ_DLJC6Z4s33cFAmCYJW7uiee+ziwDydDZ7tYdWgM0A@mail.gmail.com>
Subject: Re: [PATCH v2 00/13] Memcg Kernel Memory Tracking.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@freebsd.org>
Cc: cgroups@vger.kernel.org, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Fri, Mar 9, 2012 at 12:39 PM, Suleiman Souhlal <ssouhlal@freebsd.org> wrote:
> This is v2 of my kernel memory tracking patchset for memcg.

I just realized that I forgot to test without the config option
enabled, so that doesn't compile. :-(

I will make sure to fix this in v3 and test more thoroughly.

Hopefully this shouldn't impede discussion on the patchset.

Sorry about that.
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
