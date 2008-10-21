Message-ID: <48FD943D.5090709@cn.fujitsu.com>
Date: Tue, 21 Oct 2008 16:35:09 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>	<48FD6901.6050301@linux.vnet.ibm.com>	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>	<48FD74AB.9010307@cn.fujitsu.com>	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>	<48FD7EEF.3070803@cn.fujitsu.com>	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>	<48FD82E3.9050502@cn.fujitsu.com> <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 15:21:07 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
>> dmesg is attached.
>>
> Thanks....I think I caught some. (added Mel Gorman to CC:)
> 
> NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> 
> So, If there is a hole between zone, node->spanned_pages doesn't mean
> length of node's memmap....(then, some hole can be skipped.)
> 
> OMG....Could you try this ? 
> 

No luck, the same bug still exists. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
