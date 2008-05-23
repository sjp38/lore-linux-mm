Message-Id: <48362F2A.40506@mxp.nes.nec.co.jp>
Date: Fri, 23 May 2008 11:42:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <48350F15.9070007@mxp.nes.nec.co.jp> <20080522164421.84849565.kamezawa.hiroyu@jp.fujitsu.com> <48362795.9020709@mxp.nes.nec.co.jp>
In-Reply-To: <48362795.9020709@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

(sorry, I sent the previous mail before completing it)

On 2008/05/23 11:10 +0900, Daisuke Nishimura wrote:
> On 2008/05/22 16:44 +0900, KAMEZAWA Hiroyuki wrote:
(snip)
>>> - make it possible for users to select if they use
>>>   this feature or not, and avoid overhead for users
>>>   not using this feature.
>>> - move charges along with task move between cgroups.
>>>
>> I think memory-controller's anon pages should also do this....
> 
I want it too.

Not only it's usefull for users IMHO,
but alsoI need it to charge a swap to the group which the task
belongs to at the point of swapout.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
