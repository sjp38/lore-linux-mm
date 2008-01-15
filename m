Date: Tue, 15 Jan 2008 10:24:22 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080115101803.1183.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080114170804.b5961aea.randy.dunlap@oracle.com> <20080115101803.1183.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080115102327.1186.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> > 1/ I don't see the file below listed in the diffstat above...
> 
> Agghh...
> sorry, it is mistake.
> I repost soon. 
> 
> thanks.

the below diffstat is correct.
thanks!

------------------------------
 Documentation/devices.txt  |    1
 drivers/char/mem.c         |    6 ++
 include/linux/mem_notify.h |   42 +++++++++++++++++
 include/linux/mmzone.h     |    1
 mm/Makefile                |    2
 mm/mem_notify.c            |  109 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |    1
 7 files changed, 161 insertions(+), 1 deletion(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
