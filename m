Date: Tue, 4 Mar 2008 15:38:00 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 03/21] use an array for the LRU pagevecs
Message-ID: <20080304153800.4cadcc93@cuia.boston.redhat.com>
In-Reply-To: <20080304200209.1EAB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080229154056.GF28849@shadowen.org>
	<20080301153941.528A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080304200209.1EAB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Mar 2008 20:04:05 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Rik
> 
> this is fixed patch of Andy Whitcroft's point out.
> (at least, I hope it)

Applied, except for the documentation to ____pagevec_lru_add, since
that function should, IMHO, probably stay internal to the VM and not
be exposed in documentation.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
