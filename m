Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 078E06B004F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:58:09 -0400 (EDT)
Received: by pxi14 with SMTP id 14so975072pxi.19
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 12:58:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 3 Sep 2009 01:28:17 +0530
Message-ID: <661de9470909021258j7fcc71fcv27d284738d1e37e3@mail.gmail.com>
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 2, 2009 at 2:59 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'm sorry that I'll be absent tomorrow. This is dump of current code.
> IMHO, this version is enough simple.
>
> My next target is css's refcnt per page. I think we never need it...

Is this against 27th August 2009 mmotm?

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
