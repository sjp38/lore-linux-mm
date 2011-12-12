Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D522E6B00D5
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 04:28:28 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F0A423EE0BC
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:28:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D511345DEEF
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:28:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B5B45DEEB
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:28:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAB8D1DB803E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:28:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 577B11DB803B
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:28:26 +0900 (JST)
Date: Mon, 12 Dec 2011 18:27:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
Message-Id: <20111212182711.3a072358.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111212094930.9d4716e1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323466526.27746.29.camel@joe2Laptop>
	<1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
	<20111212094930.9d4716e1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Andrew Morton (commit_signer:15/23=65%)" <akpm@linux-foundation.org>, "Hugh Dickins (commit_signer:7/23=30%)" <hughd@google.com>, "Peter Zijlstra (commit_signer:4/23=17%)" <a.p.zijlstra@chello.nl>, "Shaohua Li (commit_signer:3/23=13%)" <shaohua.li@intel.com>

On Mon, 12 Dec 2011 09:49:30 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri,  9 Dec 2011 17:48:40 -0500
> kosaki.motohiro@gmail.com wrote:
> 
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > commit 297c5eee37 (mm: make the vma list be doubly linked) added
> > vm_prev member into vm_area_struct. Therefore we can simplify
> > find_vma_prev() by using it. Also, this change help to improve
> > page fault performance because it has strong locality of reference.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Hmm, your work remind me of a patch I tried in past.
Here is a refleshed one...how do you think ?

==
