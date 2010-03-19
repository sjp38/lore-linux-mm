Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ADC4D6B01AC
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:50:48 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 14:59:33 -0400
Message-Id: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/6] Mempolicy:  additional cleanups
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Here is a series of proposed memory policy cleanup patches, mostly
in the 'mpol' mount option parsing function 'mpol_parse_str()'.  I
came across these cleanup opportunities reviewing and testing
Kosaki Motohiro's 5 patch tmpfs series from 16mar.  This series applies
atop Kosaki-san's series.

Patch 5 of the series is more of a bug fix to get_mempolicy() discovered
while testing the other patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
