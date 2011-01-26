Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BDAA06B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:22:04 -0500 (EST)
Date: Wed, 26 Jan 2011 16:21:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memsw: handle swapaccount kernel parameter correctly
Message-ID: <20110126152158.GA4144@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
I am sorry but the patch which added swapaccount parameter is not
correct (we have discussed it https://lkml.org/lkml/2010/11/16/103).
I didn't get the way how __setup parameters are handled correctly.
The patch bellow fixes that.

I am CCing stable as well because the patch got into .37 kernel.

---
