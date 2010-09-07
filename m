Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5E4426B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 21:59:07 -0400 (EDT)
Date: Mon, 6 Sep 2010 20:59:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 13/14] mm: mempolicy: Check return code of check_range
In-Reply-To: <20100906093610.C8B5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009062058270.1485@router.home>
References: <1283711588-7628-1-git-send-email-segooon@gmail.com> <20100906093610.C8B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kulikov Vasiliy <segooon@gmail.com>, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010, KOSAKI Motohiro wrote:

> I think both case is not happen in real. Am I overlooking anything?

Its good to check the return code regardless. There is a lot of tinkering
going on with that code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
