Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7B116B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 12:34:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so1004856wra.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 09:34:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q7si3593524edl.274.2017.09.18.09.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Sep 2017 09:34:43 -0700 (PDT)
Date: Mon, 18 Sep 2017 09:34:34 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Detecting page cache trashing state
Message-ID: <20170918163434.GA11236@cmpxchg.org>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <150549651001.4512.15084374619358055097@takondra-t460s>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taras Kondratiuk <takondra@cisco.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Taras,

On Fri, Sep 15, 2017 at 10:28:30AM -0700, Taras Kondratiuk wrote:
> Quoting Michal Hocko (2017-09-15 07:36:19)
> > On Thu 14-09-17 17:16:27, Taras Kondratiuk wrote:
> > > Has somebody faced similar issue? How are you solving it?
> > 
> > Yes this is a pain point for a _long_ time. And we still do not have a
> > good answer upstream. Johannes has been playing in this area [1].
> > The main problem is that our OOM detection logic is based on the ability
> > to reclaim memory to allocate new memory. And that is pretty much true
> > for the pagecache when you are trashing. So we do not know that
> > basically whole time is spent refaulting the memory back and forth.
> > We do have some refault stats for the page cache but that is not
> > integrated to the oom detection logic because this is really a
> > non-trivial problem to solve without triggering early oom killer
> > invocations.
> > 
> > [1] http://lkml.kernel.org/r/20170727153010.23347-1-hannes@cmpxchg.org
> 
> Thanks Michal. memdelay looks promising. We will check it.

Great, I'm obviously interested in more users of it :) Please find
attached the latest version of the patch series based on v4.13.

It needs a bit more refactoring in the scheduler bits before
resubmission, but it already contains a couple of fixes and
improvements since the first version I sent out.

Let me know if you need help rebasing to a different kernel version.

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sched-loadavg-consolidate-LOAD_INT-LOAD_FRAC-macros.patch"


--xHFwDpU9dbj6ez1V--
