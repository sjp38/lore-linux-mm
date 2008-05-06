Date: Tue, 06 May 2008 12:29:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 1/5] fix overflow problem of do_try_to_free_page()
In-Reply-To: <20080505081239.GB22105@us.ibm.com>
References: <20080504215331.8F55.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080505081239.GB22105@us.ibm.com>
Message-Id: <20080506122626.AC58.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I'll repost patch 2-5 after refrect reviewer comment.
but I hope patch [1/5] merge into -mm soon.

Nishanth-san already acked me.
please.


> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Eep, sorry -- my original version had used -EAGAIN to indicate a special
> condition, but this was removed before the final patch. Thanks for the
> catch.
> 
> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Should go upstream, as well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
