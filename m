Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6AE398D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:55:47 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T7tjL8006282
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 16:55:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 84A0845DE67
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:55:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9E6045DE57
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:55:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 79EABE1800A
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:55:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B54BE38002
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:55:43 +0900 (JST)
Date: Fri, 29 Oct 2010 16:50:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 05/11] writeback: create dirty_info structure
Message-Id: <20101029165012.ec0574ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1288336154-23256-6-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-6-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 00:09:08 -0700
Greg Thelen <gthelen@google.com> wrote:

> Bundle dirty limits and dirty memory usage metrics into a dirty_info
> structure to simplify interfaces of routines that need all.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
