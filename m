From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH] syctl for selecting global zonelist[] order
Date: Wed, 25 Apr 2007 11:31:13 +0200
References: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com> <20070425004214.e21da2d8.akpm@linux-foundation.org>
In-Reply-To: <20070425004214.e21da2d8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704251131.13770.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> hm.  Why don't we use that ordering all the time?  Does the present ordering have
> any advantage?

At least on x86-64 it would make sense to change this always

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
