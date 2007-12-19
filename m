Date: Wed, 19 Dec 2007 14:17:53 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 10/20] SEQ replacement for anonymous pages
In-Reply-To: <20071218211549.536791435@redhat.com>
References: <20071218211539.250334036@redhat.com> <20071218211549.536791435@redhat.com>
Message-Id: <20071219140904.9858.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Hi Rik-san,

> To keep the maximum amount of necessary work reasonable, we scale the
> active to inactive ratio with the size of memory, using the formula
> active:inactive ratio = sqrt(memory in GB * 10).

Great.

why do you think best formula is sqrt(GB*10)?
please tell me if you don't mind.

and i have a bit worry to it works well or not on small systems.
because it is indicate 1:1 ratio on less than 100MB memory system.
Do you think this viewpoint?


/kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
