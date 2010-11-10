Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E68246B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 07:52:02 -0500 (EST)
Date: Wed, 10 Nov 2010 13:51:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] Make swap accounting default behavior configurable
Message-ID: <20101110125154.GC5867@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
could you consider the patch bellow? It basically changes the default
swap accounting behavior (when it is turned on in configuration) to be
configurable as well. 

The rationale is described in the patch but in short it makes it much
more easier to enable this feature in distribution kernels as the
functionality can be provided in the general purpose kernel (with the
option disabled) without any drawbacks and interested users can enable
it. This is not possible currently.

I am aware that boot command line parameter name change is not ideal but
the original semantic wasn't good enough and I don't like
noswapaccount=yes|no very much. 

If we really have to stick to it I can rework the patch to keep the name
and just add the yes|no logic, though. Or we can keep the original one
and add swapaccount paramete which would mean the oposite as the other
one.

The patch is based on the current Linus tree.

Any thoughts?
---
