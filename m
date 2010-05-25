Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3320D6B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 19:09:08 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o4PN94Fp026890
	for <linux-mm@kvack.org>; Tue, 25 May 2010 16:09:04 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by wpaz1.hot.corp.google.com with ESMTP id o4PN92bQ001398
	for <linux-mm@kvack.org>; Tue, 25 May 2010 16:09:03 -0700
Received: by pxi19 with SMTP id 19so2053413pxi.3
        for <linux-mm@kvack.org>; Tue, 25 May 2010 16:09:02 -0700 (PDT)
Date: Tue, 25 May 2010 16:08:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mempolicy: ERR_PTR dereference in
 mpol_shared_policy_init()
In-Reply-To: <20100525215401.GA2506@bicker>
Message-ID: <alpine.DEB.2.00.1005251608440.10919@chino.kir.corp.google.com>
References: <20100525215401.GA2506@bicker>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Dan Carpenter wrote:

> The original code called mpol_put(new) while "new" was an ERR_PTR.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
