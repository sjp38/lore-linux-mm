Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 626A96B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 07:22:42 -0400 (EDT)
Received: by ied10 with SMTP id 10so18097405ied.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 04:22:41 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 2 Oct 2012 08:22:41 -0300
Message-ID: <CALF0-+UvHP2RTGwPuHM1HE0VTBWUm_pDATap7C5V7+MMqwbdsA@mail.gmail.com>
Subject: sl[aou]b allocator comparison
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

I'd like to know what's the current status of each allocator regarding
its targeted scenario.
According to my numbers:

* slob
  very small static footprint, low internal fragmentation, doesn't scale well.
  targeted at really small embedded.

* slub
  default allocator, low internal fragmentation, suites well most scenarios.

* slab
  high internal fragmentation, we still have it because slub showed some unfixed
  (performance?) regression in some scenario.

Anyone can add anything useful to this quick comparison?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
