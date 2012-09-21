Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 95D496B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:07:38 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9047794pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:07:37 -0700 (PDT)
Date: Fri, 21 Sep 2012 13:07:33 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 09/16] sl[au]b: always get the cache from its page
 in kfree
Message-ID: <20120921200733.GM7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-10-git-send-email-glommer@parallels.com>
 <00000139d9fe8595-8905906d-18ed-4d41-afdb-f4c632c2d50a-000000@email.amazonses.com>
 <5059777E.8060906@parallels.com>
 <CAOJsxLFgwOqUcLHEwYNERwn1Uvp4-8CmvRKTfBFAHD6p_-6c7g@mail.gmail.com>
 <505C33D3.5000202@parallels.com>
 <alpine.LFD.2.02.1209211240410.3619@tux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1209211240410.3619@tux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>

Hello,

On Fri, Sep 21, 2012 at 12:41:52PM +0300, Pekka Enberg wrote:
> > I am already using static keys extensively in this patchset, and that is
> > how I intend to handle this particular case.
> 
> Cool.
> 
> The key point here is that !CONFIG_MEMCG_KMEM should have exactly *zero* 
> performance impact and CONFIG_MEMCG_KMEM disabled at runtime should have 
> absolute minimal impact.

Not necessarily disagreeing, but I don't think it's helpful to set the
bar impossibly high.  Even static_key doesn't have "exactly *zero*"
impact.  Let's stick to as minimal as possible when not in use and
reasonable in use.

And, yeah, this one can be easily solved by using static_key.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
