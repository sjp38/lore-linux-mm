Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id CF7F36B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 08:50:05 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so5355669qgd.9
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 05:50:03 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id k12si28590157qav.129.2014.07.21.05.50.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 05:50:03 -0700 (PDT)
Received: by mail-qg0-f42.google.com with SMTP id j5so5331413qga.15
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 05:50:02 -0700 (PDT)
Date: Mon, 21 Jul 2014 08:49:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140721124958.GD12921@htj.dyndns.org>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
 <20140718154443.GM27940@esperanza>
 <20140721090724.GA8393@dhcp22.suse.cz>
 <20140721114655.GB8393@dhcp22.suse.cz>
 <20140721120332.GB11848@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140721120332.GB11848@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Jul 21, 2014 at 04:03:32PM +0400, Vladimir Davydov wrote:
> I think it's all about how we're going to use memory cgroups. If we're
> going to use them for application containers, there's simply no such
> problem, because we only want to isolate a potentially dangerous process
> group from the rest of the system. If we want to start a fully
> virtualized OS inside a container, then we certainly need a kind of

For shell environments, ulimit is a much better specific protection
mechanism against fork bombs and process-granular OOM killers would
behave mostly equivalently during fork bombing to the way it'd behave
in the host environment w/o cgroups.  I'm having a hard time seeing
why this would need any special treatment from cgroups.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
