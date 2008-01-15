Date: Tue, 15 Jan 2008 10:20:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080114170804.b5961aea.randy.dunlap@oracle.com>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080114170804.b5961aea.randy.dunlap@oracle.com>
Message-Id: <20080115101803.1183.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi randy

> Hi,
> 
> 1/ I don't see the file below listed in the diffstat above...

Agghh...
sorry, it is mistake.
I repost soon. 

thanks.


> 2/ Where is the userspace interface information for the syscall?

No.
userspace interface is only poll(2).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
