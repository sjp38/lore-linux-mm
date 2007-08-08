Date: Wed, 8 Aug 2007 12:51:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm PATCH 0/9] Memory controller introduction (v4)
Message-Id: <20070808125139.7cfe702c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727200937.31565.78623.sendpatchset@balbir-laptop>
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007 01:39:37 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> At OLS, the resource management BOF, it was discussed that we need to manage
> RSS and unmapped page cache together. This patchset is a step towards that
> 
Can I make a question ? Why limiting RSS instead of # of used pages per
container ? Maybe bacause of shared pages between container.... 
I'm sorry that I don't have much knowledge about history of this work.
If already discussed, the pointer to log is helpful.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
