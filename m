Date: Sat, 23 Feb 2008 17:18:21 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
In-Reply-To: <20080223000426.adf5c75a.akpm@linux-foundation.org>
References: <47BE4FB5.5040902@linux.vnet.ibm.com> <20080223000426.adf5c75a.akpm@linux-foundation.org>
Message-Id: <20080223171647.AE7E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, menage@google.com, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

> yup, I agree.  Even though I don't know what ILP32 and LP64 are ;)

ILP32: integer and long and pointer size is 32bit
LP64:  long and pointer size is 64bit, but int size is 32bit

linux 32bit kernel obey ILP32 model, 64bit kernel obey LP64.

Thanks.


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
