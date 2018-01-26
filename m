Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4DE6B0003
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 19:08:42 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l37so2624563wrl.1
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 16:08:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k136si5038959wmd.93.2018.01.27.16.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 16:08:40 -0800 (PST)
Date: Fri, 26 Jan 2018 17:05:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] MM maintenance process
Message-ID: <20180126160522.GG5027@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,
I have started this topic last year already but I think we should get
back to it.

Basically I would like to talk about the future of the MM subsystem
maintenance process. I feel we should be following other
subsystems by having multi-maintainers hierarchical model. The amount
of changes is not decreasing, quite contrary, and that puts a lot of
pressure on Andrew.

Last year I have presented that around half of MM changes are not
reviewed properly and that is simply not acceptable for the core
subsystem IMHO. Numbers haven't changed much since then I am afraid.
We have roughly 200 commits each major release which is a lot!
$ git rev-list v4.11..v4.15-rc9 -- mm/ | wc -l
808
$ git rev-list v4.11..v4.15-rc9 -- mm/ | xargs git-grep-changelog.sh "Acked-by:\|Reviewed-by:" | wc -l
439
so only ~55% gets an active review. Please note that these are only
rough numbers because not all of those are s-o-b Andrew. This also only
considers mm/ directory, while there are other MM parts outside (arch
code etc.). By no means I do not want to blame Andrew here.

Where do I see problems?
* most people are busy to do review. I _think_ that having more explicit
  maintainers for MM parts would help with the "responsibility for the
  code".  People do care more when they are officially responsible for
  the code. It wouldn't be all on Andrew's shoulders.
* It is quite hard for non-regular developers to get how the MM subsystem
  works because it is so much different from other subystems. There
  is no standard git tree to develop agains (except for linux-next
  which is not ideal for long term developing).  I've been maintaining
  non-rebased mmotm git tree and Johannes does reconstruct each mmomt
  into git from scratch but not all people know about that and this is
  more of a workaround than a real solution
* mmotm process with early merging strategy and many fixups is not really
  ideal IMHO. Andrew is good in tracking those changes but my experience
  is that it encourages half baked work to be posted and then fixed
  up later. It is also quite hard to keep mental model of the series
  after multiple fixups.
* MM is a core kernel subsystem and relying on the single maintainer
  is hardly sustainable long term. 200 patches/release is a lot!
  We should share the responsibility.
* linux-next is quite a pain to work with due to constant rebases and
  non-stable sha1. I cannot count how many times I had to note that
  Fixes: $sha1 is not valid for mmotm patches.

What I would like to see and propose?
* tip like multi-maintainer git model, where Andrew doesn't have to
  care about each and every patch and rather rely on sub-maintainers.
  Andrew said he highly relies on people anyway. Doing the above would
  save him from a lot of paper work and email traffic.
* we _really_ need much more high level review. I think Andrew is really
  good at that. Giving him more time by reducing the email/patch flow at
  him sounds like a reasonable step to get there.

I suspect all this is for longer discussion so I would propose to give
it 40min - 60min slot.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
