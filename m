Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id m9T5nKqG008087
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 05:49:20 GMT
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz17.hot.corp.google.com with ESMTP id m9T5nIUV007752
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 22:49:18 -0700
Received: by rv-out-0708.google.com with SMTP id c5so2859585rvf.28
        for <linux-mm@kvack.org>; Tue, 28 Oct 2008 22:49:18 -0700 (PDT)
Message-ID: <6599ad830810282249t1837252bn2d4904faabf81af1@mail.gmail.com>
Date: Tue, 28 Oct 2008 22:49:18 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [discuss][memcg] oom-kill extension
In-Reply-To: <20081029144539.b6c96cb8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830810282235w5ad7ff7cx4f8be4e1f58933a5@mail.gmail.com>
	 <20081029144539.b6c96cb8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 28, 2008 at 10:45 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> the userland can know "bad process" under group ?

Not in our current implementation - that's something that might be
good to add if we were doing a proper API for inclusion in mainline.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
