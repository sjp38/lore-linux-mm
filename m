Date: Tue, 11 Mar 2008 19:23:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] memcg: put a restriction on writing
 memory.force_empty
Message-Id: <20080311192338.9f89ca70.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47D65BAA.60908@linux.vnet.ibm.com>
References: <47D65A36.4020008@cn.fujitsu.com>
	<47D65BAA.60908@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 15:45:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Li Zefan wrote:
> > We can write whatever to memory.force_empty:
> > 
> >         echo 999 > memory.force_empty
> >         echo wow > memory.force_empty
> > 
> > This is odd, so let's make '1' to be the only valid value.
> 
> I suspect as long as there is no unreasonable side-effect, writing 999 or wow
> should be OK.
> 
I agree with Balbir.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
