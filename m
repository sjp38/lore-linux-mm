Date: Sat, 21 Aug 1999 16:43:46 +0900
From: Neil Booth <NeilB@earthling.net>
Subject: Re: =?iso-2022-jp?B?GyRCO1g4NBsoQg==?= : where does vmlist be initiated?
Message-ID: <19990821164346.A13013@monkey.rosenet.ne.jp>
References: <000801beeb7e$5ed16360$0601a8c0@honey.cs.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
In-Reply-To: <000801beeb7e$5ed16360$0601a8c0@honey.cs.tsinghua.edu.cn>; from Wang Yong on Sat, Aug 21, 1999 at 10:38:57AM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wang Yong <wangyong@sun475.cs.tsinghua.edu.cn>
Cc: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wang Yong wrote:-
> 
> struct vm_struct * get_vm_area(unsigned long size)
> {
> ...
>  for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
>   if (size + addr < (unsigned long) tmp->addr)
> ...
>  }
> }

[SNIP]

> i think these three functions will not be able to work if vmlist is null. do
> you think so?

They must work as Linux boots.  The key is in the snippet I've kept above.
The test in

for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {

is probably more clearly written as

(tmp = *p) != 0

which fails when vmlist is initially zero, so the loop never executes.
Note p does not hold the value of vmlist, but the address of vmlist.

vmlist is then initialised by the 

*p = area;

that comes a few lines later.

Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
