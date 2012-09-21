Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A64846B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:14:47 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so2285111wib.2
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:14:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120921200733.GM7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
	<1347977530-29755-10-git-send-email-glommer@parallels.com>
	<00000139d9fe8595-8905906d-18ed-4d41-afdb-f4c632c2d50a-000000@email.amazonses.com>
	<5059777E.8060906@parallels.com>
	<CAOJsxLFgwOqUcLHEwYNERwn1Uvp4-8CmvRKTfBFAHD6p_-6c7g@mail.gmail.com>
	<505C33D3.5000202@parallels.com>
	<alpine.LFD.2.02.1209211240410.3619@tux.localdomain>
	<20120921200733.GM7264@google.com>
Date: Fri, 21 Sep 2012 23:14:45 +0300
Message-ID: <CAOJsxLFgK3=Eu1UQt8NOSe30824UcuxZftxD1xnpkOt3MepOVg@mail.gmail.com>
Subject: Re: [PATCH v3 09/16] sl[au]b: always get the cache from its page in kfree
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>

On Fri, Sep 21, 2012 at 11:07 PM, Tejun Heo <tj@kernel.org> wrote:
> Not necessarily disagreeing, but I don't think it's helpful to set the
> bar impossibly high.  Even static_key doesn't have "exactly *zero*"
> impact.  Let's stick to as minimal as possible when not in use and
> reasonable in use.

For !CONFIG_MEMCG_KMEM, it should be exactly zero. No need to play
games with static_key.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
