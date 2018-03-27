Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE456B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 22:06:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k17-v6so10233105ita.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 19:06:19 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0096.hostedemail.com. [216.40.44.96])
        by mx.google.com with ESMTPS id c65si95277iof.340.2018.03.26.19.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 19:06:18 -0700 (PDT)
Message-ID: <1522116373.12357.42.camel@perches.com>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
From: Joe Perches <joe@perches.com>
Date: Mon, 26 Mar 2018 19:06:13 -0700
In-Reply-To: <1e8c4382-b97f-659a-59fa-07c71efad970@oracle.com>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
	 <20180102222341.GB20405@bombadil.infradead.org>
	 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
	 <20180104013807.GA31392@tardis>
	 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
	 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
	 <20180104214658.GA20740@bombadil.infradead.org>
	 <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
	 <20180104231307.GA794@bombadil.infradead.org>
	 <20180104234732.GM9671@linux.vnet.ibm.com>
	 <20180105000707.GA22237@bombadil.infradead.org>
	 <1515134773.21222.13.camel@perches.com>
	 <1e8c4382-b97f-659a-59fa-07c71efad970@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>, Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Mon, 2018-03-26 at 18:56 -0700, Rao Shoaib wrote:
> Folks,
> 
> Is anyone working on resolving the check patch issue as I am waiting to 
> resubmit my patch. Will it be fine if I submitted the patch with the 
> original macro as the check is in-correct.

Yes.  Of course.  Anytime a person knows better,
checkpatch output should be ignored.

> I do not speak perl but I can do the process work. If folks think Joe's 
> fix is fine I can submit it and perhaps someone can review it ?

I think it's fine too ;)
Submit away...
