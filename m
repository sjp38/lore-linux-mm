Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7DA6B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 20:37:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E9B213EE0B6
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:37:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE84345DE70
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:37:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B634445DE4D
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:37:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7ADAE08001
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:37:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 685421DB8037
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:37:38 +0900 (JST)
Date: Thu, 9 Jun 2011 09:30:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

