Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EAA466B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 19:42:20 -0500 (EST)
Received: by lamb11 with SMTP id b11so576107lam.14
        for <linux-mm@kvack.org>; Sun, 27 Nov 2011 16:42:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322062951-1756-3-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-3-git-send-email-hannes@cmpxchg.org>
Date: Mon, 28 Nov 2011 06:12:17 +0530
Message-ID: <CAKTCnzmO6P1B_8kGG5tPOrWAb6PT0byOZ4WQdfWwbaHAX7shww@mail.gmail.com>
Subject: Re: [patch 2/8] mm: unify remaining mem_cont, mem, etc. variable
 names to memcg
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 23, 2011 at 9:12 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> From: Johannes Weiner <jweiner@redhat.com>
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>


I am not very comfortable with memcgp, I'd prefer the name to
represent something more useful especially when it is an output
parameter. Having said that I don't think it is a stopper for the
patch

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
