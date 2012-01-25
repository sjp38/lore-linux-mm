Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2644B6B004D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 20:55:03 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so153681wib.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 17:55:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120124082352.GA26289@tiehlicka.suse.cz>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
	<20120123130221.GA15113@tiehlicka.suse.cz>
	<CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
	<CAJd=RBAuDABE7u1wyc+45ZGoVos5PnxMe6P=ET-CHf-LChTpgw@mail.gmail.com>
	<20120124082352.GA26289@tiehlicka.suse.cz>
Date: Wed, 25 Jan 2012 09:55:01 +0800
Message-ID: <CAJd=RBDj5mtWJG0Byi=97Kuu6LnkwdndDO-AUpeYSCTBEy0P5A@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jan 24, 2012 at 4:23 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Barriered?
>
pushed out for 3.3-rc2 last night?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
