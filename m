Date: Wed, 05 Mar 2008 10:38:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 03/21] use an array for the LRU pagevecs
In-Reply-To: <20080304153800.4cadcc93@cuia.boston.redhat.com>
References: <20080304200209.1EAB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080304153800.4cadcc93@cuia.boston.redhat.com>
Message-Id: <20080305103754.1EBA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > this is fixed patch of Andy Whitcroft's point out.
> > (at least, I hope it)
> 
> Applied, except for the documentation to ____pagevec_lru_add, since
> that function should, IMHO, probably stay internal to the VM and not
> be exposed in documentation.

That makes sense.
Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
