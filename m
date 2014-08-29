Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9CF46B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 19:31:41 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so7432907pab.24
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:31:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id f5si2299206pat.150.2014.08.29.16.31.39
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 16:31:40 -0700 (PDT)
Date: Sat, 30 Aug 2014 07:28:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 251/287] lib/test-string_helpers.c:293:1: warning:
 the frame size of 1316 bytes is larger than 1024 bytes
Message-ID: <54010c8c.wA2PyooCbGtrpuaG%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
commit: 626105764fd29c75bd8b01d36b54d0aaca61ac36 [251/287] lib / string_helpers: introduce string_escape_mem()
config: make ARCH=i386 allyesconfig

All warnings:

   lib/test-string_helpers.c: In function 'test_string_escape':
>> lib/test-string_helpers.c:293:1: warning: the frame size of 1316 bytes is larger than 1024 bytes [-Wframe-larger-than=]
    }
    ^

vim +293 lib/test-string_helpers.c

   277				continue;
   278	
   279			/* Copy string to in buffer */
   280			len = strlen(s2->in);
   281			memcpy(&in[p], s2->in, len);
   282			p += len;
   283	
   284			/* Copy expected result for given flags */
   285			len = strlen(out);
   286			memcpy(&out_test[q_test], out, len);
   287			q_test += len;
   288		}
   289	
   290		q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
   291	
   292		test_string_check_buf(name, flags, in, p, out_real, q_real, out_test, q_test);
 > 293	}
   294	
   295	static __init void test_string_escape_nomem(void)
   296	{
   297		char *in = "\eb \\C\007\"\x90\r]";
   298		char out[64], *buf = out;
   299		int rc = -ENOMEM, ret;
   300	
   301		ret = string_escape_str_any_np(in, &buf, strlen(in), NULL);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
