Message-Id: <000801beeb7e$5ed16360$0601a8c0@honey.cs.tsinghua.edu.cn>
From: "Wang Yong" <wangyong@sun475.cs.tsinghua.edu.cn>
Subject: =?ISO-8859-1?Q?=BB=D8=B8=B4:?= where does vmlist be initiated?
Date: Sat, 21 Aug 1999 10:38:57 +0800
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Booth <NeilB@earthling.net>
Cc: linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

-----Original Message-----
.c 1/4 thEE: Neil Booth <NeilB@earthling.net>
EO 1/4 thEE: Wang Yong <wung_y@263.net>
3-EI: Linux-MM <
EOAEU: 1999Ae8OA19EO 4:03
O/Ia: Re: where does vmlist be initiated?


>
>Hi Wang,
>
>There's only 3 lines that reference it in vmalloc.c, so it
>shouldn't be too hard to figure out, no?
>
>Neil.
>

Hi Neil,
  yes, vmlist does only referenced three times in vmalloc.c after it's
defined as NULL. These references are the only reference of vmlist
throughout the whole kernel. let's check them:

struct vm_struct * get_vm_area(unsigned long size)
{
...
 for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
  if (size + addr < (unsigned long) tmp->addr)
...
 }
}

void vfree(void * addr)
{
 for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
...
 }
}

long vread(char *buf, char *addr, unsigned long count)
{
...
 for (tmp = vmlist; tmp; tmp = tmp->next) {
...
 }
}

i think these three functions will not be able to work if vmlist is null. do
you think so?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
