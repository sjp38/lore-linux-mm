Message-ID: <000301bf0cb4$cbd31c40$0601a8c0@honey.cs.tsinghua.edu.cn>
From: "Alan Wang" <wung_y@263.net>
Subject: about get_pte_fast and more
Date: Sat, 2 Oct 1999 17:02:03 +0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, all:
 I am studying the source code of mm in linux. Here, I have a question and I
am looking forward for any of your comments.
 The question have bother me for a long time is about some functions defined
in arch/i386/pgtable.h. to make it clear, I paste one of them here:

extern __inline__ pte_t *get_pte_fast(void)
{
 unsigned long *ret;

 if((ret = (unsigned long *)pte_quicklist) != NULL) {
  pte_quicklist = (unsigned long *)(*ret);
  ret[0] = ret[1];
  pgtable_cache_size--;
 }
 return (pte_t *)ret;
}

my questions are:
1. what is pte_quicklist and pgd_quicklist? Are they TLB?
2.what!?s on earth the function of these strange code? It appears
pte_quicklist is only a pointer to long integer but never a list and why
!(R)ret[0]=ret[1]!??

thank you.

Wang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
