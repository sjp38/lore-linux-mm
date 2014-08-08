Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7CF6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 23:00:13 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id pn19so4190079lab.10
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 20:00:12 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id bi4si1966338lbc.56.2014.08.07.20.00.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 20:00:11 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1XFaPU-0004Kw-7C
	for linux-mm@kvack.org; Fri, 08 Aug 2014 05:00:04 +0200
Received: from TOROON5037W-LP140-02-1279532811.dsl.bell.ca ([76.68.31.11])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 05:00:04 +0200
Received: from ds2horner by TOROON5037W-LP140-02-1279532811.dsl.bell.ca with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 05:00:04 +0200
From: David Horner <ds2horner@gmail.com>
Subject: [RFC 2/3] zsmalloc/zram: add =?utf-8?b?enNfZ2V0X21heF9zaXplX2J5dGVz?= and use it in zram
Date: Fri, 8 Aug 2014 02:56:24 +0000 (UTC)
Message-ID: <loom.20140808T045014-594@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


 [2/3]


 But why isn't mem_used_max writable? (save tearing down and rebuilding
 device to reset max)

 static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);

 static DEVICE_ATTR(mem_used_max, S_IRUGO | S_IWUSR, mem_used_max_show, NULL);

   with a check in the store() that the new value is positive and less
than current max?


 I'm also a little puzzled why there is a new API zs_get_max_size_bytes if
 the data is accessible through sysfs?
 Especially if max limit will be (as you propose for [3/3]) through accessed
 through zsmalloc and hence zram needn't access.



  [3/3]
 I concur that the zram limit is best implemented in zsmalloc.
 I am looking forward to that revised code.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
