Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC046B007D
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 23:45:36 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2B4fnpT014617
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 15:41:49 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2B4jVZn1548480
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 15:45:31 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2B4jUXL012256
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 15:45:31 +1100
Date: Thu, 11 Mar 2010 10:15:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: fix typo in refill_stock() comment
Message-ID: <20100311044526.GB17643@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268255117-3280-1-git-send-email-gthelen@google.com>
 <20100311093226.8f361e38.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100311093226.8f361e38.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Greg Thelen <gthelen@google.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trivial@kernel.org
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-11 09:32:26]:

> On Wed, 10 Mar 2010 13:05:17 -0800, Greg Thelen <gthelen@google.com> wrote:
> > Change refill_stock() comment: s/consumt_stock()/consume_stock()/
> > 
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>

Thanks for catching and fixing this.
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
