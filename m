Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id C35926B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:03:48 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so7905199pbb.21
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:03:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tb5si3871652pac.191.2014.01.20.22.03.46
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 22:03:47 -0800 (PST)
Date: Mon, 20 Jan 2014 22:04:28 -0800
From: Greg Kroah-Hartmann <gregkh@linuxfoundation.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20140121060428.GA19037@kroah.com>
References: <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
 <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
 <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org>
 <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
 <20140110221432.GD6963@cmpxchg.org>
 <alpine.DEB.2.02.1401121404530.20999@chino.kir.corp.google.com>
 <20140115143449.GN8782@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401151319580.10727@chino.kir.corp.google.com>
 <20140116093220.GC28157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401202155410.21729@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401202155410.21729@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, Jan 20, 2014 at 09:58:28PM -0800, David Rientjes wrote:
> The patches getting proposed through -mm for stable boggles my mind
> sometimes.

Do you have any objections to patches that I have taken for -stable?  If
so, please let me know.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
