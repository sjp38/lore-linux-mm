Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF128299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 04:15:49 -0400 (EDT)
Received: by iegc3 with SMTP id c3so93384308ieg.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 01:15:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id us10si2552353pac.206.2015.03.13.01.15.47
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 01:15:48 -0700 (PDT)
Date: Fri, 13 Mar 2015 16:15:32 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 4561/4763] lib/vsprintf.c:153:9: sparse: incorrect type
 in initializer (different base types)
Message-ID: <201503131630.eYTduLhf%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   a68b04c773c390c457b418de99f27a656dbf2339
commit: 18c9dea8d1eb5b7fdec8a054ef00ccc72d8d3ee0 [4561/4763] lib/vsprintf.c: even faster binary to decimal conversion
reproduce:
  # apt-get install sparse
  git checkout 18c9dea8d1eb5b7fdec8a054ef00ccc72d8d3ee0
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> lib/vsprintf.c:153:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:9:    expected unsigned short
   lib/vsprintf.c:153:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:16:    expected unsigned short
   lib/vsprintf.c:153:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:23:    expected unsigned short
   lib/vsprintf.c:153:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:30:    expected unsigned short
   lib/vsprintf.c:153:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:37:    expected unsigned short
   lib/vsprintf.c:153:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:44:    expected unsigned short
   lib/vsprintf.c:153:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:51:    expected unsigned short
   lib/vsprintf.c:153:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:58:    expected unsigned short
   lib/vsprintf.c:153:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:65:    expected unsigned short
   lib/vsprintf.c:153:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:153:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:153:72:    expected unsigned short
   lib/vsprintf.c:153:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:9:    expected unsigned short
   lib/vsprintf.c:154:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:16:    expected unsigned short
   lib/vsprintf.c:154:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:23:    expected unsigned short
   lib/vsprintf.c:154:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:30:    expected unsigned short
   lib/vsprintf.c:154:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:37:    expected unsigned short
   lib/vsprintf.c:154:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:44:    expected unsigned short
   lib/vsprintf.c:154:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:51:    expected unsigned short
   lib/vsprintf.c:154:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:58:    expected unsigned short
   lib/vsprintf.c:154:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:65:    expected unsigned short
   lib/vsprintf.c:154:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:154:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:154:72:    expected unsigned short
   lib/vsprintf.c:154:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:9:    expected unsigned short
   lib/vsprintf.c:155:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:16:    expected unsigned short
   lib/vsprintf.c:155:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:23:    expected unsigned short
   lib/vsprintf.c:155:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:30:    expected unsigned short
   lib/vsprintf.c:155:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:37:    expected unsigned short
   lib/vsprintf.c:155:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:44:    expected unsigned short
   lib/vsprintf.c:155:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:51:    expected unsigned short
   lib/vsprintf.c:155:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:58:    expected unsigned short
   lib/vsprintf.c:155:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:65:    expected unsigned short
   lib/vsprintf.c:155:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:155:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:155:72:    expected unsigned short
   lib/vsprintf.c:155:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:9:    expected unsigned short
   lib/vsprintf.c:156:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:16:    expected unsigned short
   lib/vsprintf.c:156:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:23:    expected unsigned short
   lib/vsprintf.c:156:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:30:    expected unsigned short
   lib/vsprintf.c:156:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:37:    expected unsigned short
   lib/vsprintf.c:156:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:44:    expected unsigned short
   lib/vsprintf.c:156:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:51:    expected unsigned short
   lib/vsprintf.c:156:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:58:    expected unsigned short
   lib/vsprintf.c:156:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:65:    expected unsigned short
   lib/vsprintf.c:156:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:156:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:156:72:    expected unsigned short
   lib/vsprintf.c:156:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:9:    expected unsigned short
   lib/vsprintf.c:157:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:16:    expected unsigned short
   lib/vsprintf.c:157:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:23:    expected unsigned short
   lib/vsprintf.c:157:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:30:    expected unsigned short
   lib/vsprintf.c:157:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:37:    expected unsigned short
   lib/vsprintf.c:157:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:44:    expected unsigned short
   lib/vsprintf.c:157:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:51:    expected unsigned short
   lib/vsprintf.c:157:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:58:    expected unsigned short
   lib/vsprintf.c:157:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:65:    expected unsigned short
   lib/vsprintf.c:157:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:157:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:157:72:    expected unsigned short
   lib/vsprintf.c:157:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:9:    expected unsigned short
   lib/vsprintf.c:158:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:16:    expected unsigned short
   lib/vsprintf.c:158:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:23:    expected unsigned short
   lib/vsprintf.c:158:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:30:    expected unsigned short
   lib/vsprintf.c:158:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:37:    expected unsigned short
   lib/vsprintf.c:158:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:44:    expected unsigned short
   lib/vsprintf.c:158:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:51:    expected unsigned short
   lib/vsprintf.c:158:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:58:    expected unsigned short
   lib/vsprintf.c:158:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:65:    expected unsigned short
   lib/vsprintf.c:158:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:158:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:158:72:    expected unsigned short
   lib/vsprintf.c:158:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:9:    expected unsigned short
   lib/vsprintf.c:159:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:16:    expected unsigned short
   lib/vsprintf.c:159:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:23:    expected unsigned short
   lib/vsprintf.c:159:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:30:    expected unsigned short
   lib/vsprintf.c:159:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:37:    expected unsigned short
   lib/vsprintf.c:159:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:44:    expected unsigned short
   lib/vsprintf.c:159:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:51:    expected unsigned short
   lib/vsprintf.c:159:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:58:    expected unsigned short
   lib/vsprintf.c:159:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:65:    expected unsigned short
   lib/vsprintf.c:159:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:159:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:159:72:    expected unsigned short
   lib/vsprintf.c:159:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:9:    expected unsigned short
   lib/vsprintf.c:160:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:16:    expected unsigned short
   lib/vsprintf.c:160:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:23:    expected unsigned short
   lib/vsprintf.c:160:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:30:    expected unsigned short
   lib/vsprintf.c:160:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:37:    expected unsigned short
   lib/vsprintf.c:160:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:44:    expected unsigned short
   lib/vsprintf.c:160:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:51:    expected unsigned short
   lib/vsprintf.c:160:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:58:    expected unsigned short
   lib/vsprintf.c:160:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:65:    expected unsigned short
   lib/vsprintf.c:160:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:160:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:160:72:    expected unsigned short
   lib/vsprintf.c:160:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:9:    expected unsigned short
   lib/vsprintf.c:161:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:16:    expected unsigned short
   lib/vsprintf.c:161:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:23:    expected unsigned short
   lib/vsprintf.c:161:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:30:    expected unsigned short
   lib/vsprintf.c:161:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:37:    expected unsigned short
   lib/vsprintf.c:161:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:44:    expected unsigned short
   lib/vsprintf.c:161:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:51:    expected unsigned short
   lib/vsprintf.c:161:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:58:    expected unsigned short
   lib/vsprintf.c:161:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:65:    expected unsigned short
   lib/vsprintf.c:161:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:161:72: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:161:72:    expected unsigned short
   lib/vsprintf.c:161:72:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:9: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:9:    expected unsigned short
   lib/vsprintf.c:162:9:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:16: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:16:    expected unsigned short
   lib/vsprintf.c:162:16:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:23: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:23:    expected unsigned short
   lib/vsprintf.c:162:23:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:30: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:30:    expected unsigned short
   lib/vsprintf.c:162:30:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:37: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:37:    expected unsigned short
   lib/vsprintf.c:162:37:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:44: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:44:    expected unsigned short
   lib/vsprintf.c:162:44:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:51: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:51:    expected unsigned short
   lib/vsprintf.c:162:51:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:58: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:58:    expected unsigned short
   lib/vsprintf.c:162:58:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:65: sparse: incorrect type in initializer (different base types)
   lib/vsprintf.c:162:65:    expected unsigned short
   lib/vsprintf.c:162:65:    got restricted __le16 [usertype] <noident>
>> lib/vsprintf.c:162:72: sparse: too many warnings
   lib/vsprintf.c:702:38: sparse: cannot size expression

vim +153 lib/vsprintf.c

   147	 * several options. The simplest is (x * 0x147b) >> 19, which is valid
   148	 * for all x <= 43698.
   149	 */
   150	
   151	static const u16 decpair[100] = {
   152	#define _(x) cpu_to_le16(((x % 10) | ((x / 10) << 8)) + 0x3030)
 > 153		_( 0), _( 1), _( 2), _( 3), _( 4), _( 5), _( 6), _( 7), _( 8), _( 9),
 > 154		_(10), _(11), _(12), _(13), _(14), _(15), _(16), _(17), _(18), _(19),
 > 155		_(20), _(21), _(22), _(23), _(24), _(25), _(26), _(27), _(28), _(29),
 > 156		_(30), _(31), _(32), _(33), _(34), _(35), _(36), _(37), _(38), _(39),
 > 157		_(40), _(41), _(42), _(43), _(44), _(45), _(46), _(47), _(48), _(49),
 > 158		_(50), _(51), _(52), _(53), _(54), _(55), _(56), _(57), _(58), _(59),
 > 159		_(60), _(61), _(62), _(63), _(64), _(65), _(66), _(67), _(68), _(69),
 > 160		_(70), _(71), _(72), _(73), _(74), _(75), _(76), _(77), _(78), _(79),
 > 161		_(80), _(81), _(82), _(83), _(84), _(85), _(86), _(87), _(88), _(89),
 > 162		_(90), _(91), _(92), _(93), _(94), _(95), _(96), _(97), _(98), _(99),
   163	#undef _
   164	};
   165	

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
