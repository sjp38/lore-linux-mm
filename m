Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D074A6B0011
	for <linux-mm@kvack.org>; Mon,  2 May 2011 16:07:33 -0400 (EDT)
Subject: memcg: fix fatal livelock in kswapd
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 15:07:29 -0500
Message-ID: <1304366849.15370.27.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

The fatal livelock in kswapd, reported in this thread:

http://marc.info/?t=130392066000001

Is mitigateable if we prevent the cgroups code being so aggressive in
its zone shrinking (by reducing it's default shrink from 0 [everything]
to DEF_PRIORITY [some things]).  This will have an obvious knock on
effect to cgroup accounting, but it's better than hanging systems.

Signed-off-by: James Bottomley <James.Bottomley@suse.de>

---
