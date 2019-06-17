Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D416C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:15:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B89DD20861
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:14:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B89DD20861
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 344028E0004; Mon, 17 Jun 2019 08:14:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F4608E0001; Mon, 17 Jun 2019 08:14:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3DC8E0004; Mon, 17 Jun 2019 08:14:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3D148E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:14:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v7so4597079wrt.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=4uTICVvnlaEhduUXZZHHwDtP16h4L4Jee+k86bD4ipc=;
        b=ZQJFGS37FkM9O98lJZVgd8kuO+afontgDpxUs5mZ74BUNP2NjH92CUclzqp8GZ6zUb
         plI8D5tLRBBRQ/r50M/FiLB8uLvV/41LvlSZuO1TAg7tm+rLWb1EQFifr1dYeWoKxOE3
         ImiIMvgwscF+muxm54QEShvlK78eGt0fkzBb6HmRDjWPNbkVEnDTo50APZThfWB6gDio
         u3ZhyZSyJYGdmDvWyfDp0tgChnTGv2R0sDH2S8ChSGcgLkOoZGGRlIeeO7cqah/gQB9P
         0JlsYhT9SQrnOOA7Qc1eNrvDirq5johp50JwEx8WWYjBVTVDGDxvm/7qq5rqaucxUNJN
         BkEw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAWChjwfDSr4h8qUZAbJRAjNG+5rMxEYoT8KOSmEAYIhKb9T2b+W
	tz2mDfb3HUbw7B/eYcJTFuRvKHVlXCYst7r5z51EK4uOjoexJPBrWtB/mHwtmWmXYh9haToZw71
	cWUNaMHnZpqkXqpsL4q3QdqxJOa0ixbNYu8NBDiy4NfYvXqkpGa9JmQ/eWfFahTU=
X-Received: by 2002:a1c:e715:: with SMTP id e21mr19461317wmh.16.1560773698195;
        Mon, 17 Jun 2019 05:14:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWT0bZZY1kD/hq0GcpqcncWznLkVt/wu+VnRCik5Kr+7R+srAuAFcVmVaOulbrjXYACM0M
X-Received: by 2002:a1c:e715:: with SMTP id e21mr19461236wmh.16.1560773697137;
        Mon, 17 Jun 2019 05:14:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560773697; cv=none;
        d=google.com; s=arc-20160816;
        b=R8pgAmpmY9UHw+wNp04HgZouFfzlniJ9njiv//zxwbwVPxmhENz16jhL+RpOz09uFW
         IUv4qA+Agv3ZIP8K1YrusiHzmRMne+3t+jTmoGxdWk4n4dBZ0psrC+5hzGfmVHHCc/BJ
         Al33XWQG1cU5iCFzCrRwI4mODfuYku+SVdHOah9Ud7DhbdCRRdHrj/yr6DvM3Um3vJHH
         Xqf0q4s/SAu+dxslftjNfaJD9z+0HYvApiinXezOtGAYjqVDkM3rVDc1nED/VUYtV+Ht
         t+vZDoIL7tCAVUhWxwd2J55mVaFYAPkSBzc5DTK537SdQ7MRg9JHzb3RCXEj+vegntC5
         KPow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=4uTICVvnlaEhduUXZZHHwDtP16h4L4Jee+k86bD4ipc=;
        b=GJzHmSB5wBg1svbTEFH9x3UCIOoKu7XUlZOv23e0sce7rzrsySM7XMrpXVEXziOPdW
         5ct1/VBUwX/h72M+Iqja9alN9qdiKbL2oHJ56et3qSAmnkffKPdSk+Rc4ZN4ol7bvjnS
         F04SzAgpcTHg7iCNLHvU9VPSSu7V60yFvZx/JljKnpF9txUPEkZ8mDq5j4UFO9m6Jtlo
         ChVc2S+jTSpOPHncLScChbnW5uUkD1Vt8Zp9Jb3WtGK6bgg16djdcXXHvP8M90uYBXW/
         OZLiPqSyPuQhX1mUhNdOL7nd5DzI8/Sl8HpxJvboghvJsuwCfPpzU9PMpI6q+3mlLijD
         lTeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id a2si352438wmf.150.2019.06.17.05.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 05:14:57 -0700 (PDT)
Received-SPF: neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=217.72.192.75;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue107 [212.227.15.145]) with ESMTPA (Nemesis) id
 1Mn1iT-1iIoa32p7v-00kBBk; Mon, 17 Jun 2019 14:14:44 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: 
Cc: Arnd Bergmann <arnd@arndb.de>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Penyaev <rpenyaev@suse.de>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [BUG]: mm/vmalloc: uninitialized variable access in pcpu_get_vm_areas
Date: Mon, 17 Jun 2019 14:14:11 +0200
Message-Id: <20190617121427.77565-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:tTeqNGd4TVlIml5CMtu2lMEK72C2cmu0L9gWMplwst9AdyblEhs
 /0GtS05lmzrqMN+S4zaQlZdDFpVtXvZDzOGUU/lEIyDDojFmYV7qBw5N800RdJ/exviAEh2
 bwxyVHQcntNpqtK3OsDbSbxrB1vvLAa9d/sppldXDeuvrcB81qPmTI0bBovbNv4DbdqOhX6
 /VeAekZToBibxtpGIUakg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:5xtYdggVb/A=://lSt3xAZ83zGcKRhCe14J
 +CuhOHiyn4wqvnJJkAfHxsJmn+sIb1JQ3abjypPEJGTzZsew1dIaDOszL54oqYOAEshi+eDRm
 jymPkZpcYMppwZfoCDckrWlK8/RidzMkTcUxoYKzRNI9FD0exgdoqu/wOqS9JkfqT8NBTTJun
 zsoeoK/LJptEQ43ByItpeW6hzvg5BHJLz+jGFu6SsEvw5kA93RvdMrJgLvsiwBfCLz2itlfkX
 Aqu/MAwQ1nHA69Ga0qIr2VDHUsEMf1sw3RUoEaAe/SkpTY65dnhsIOzccSyOtXafgEPT/PVVN
 ReseF9Rs8yM2MqTNwJ8Qec/4EQ8ikeiME+An4TXwic7SCmsfgKiNspk5eaYWLGD5Hprgu5dC7
 OgsfkSqwXf0M1d9kbS0t8R22rQg6q+vYChxvYspng5AjkdAjhQPfHGlelY3sqSfaipWuh/0K+
 pRuPrQK2vez1y+1cOGcsuI0LWa5/dwqUkl9cCq29nn9dxTkQzhimFk1OoAqTEZ5Li88iOIjT/
 cIbXwWiEDsCd44CPzNXFWTXjmmvfs53T8GUPir6iK0L+n029eFmS9Y9q8cDVeSEZQoWItCVyO
 ybQPzt+Hv79ihJrzbAh2tOsZ2DHcKazrYMi3AdajY2sJhlONFxC75LkJ62KG0q5/telLrRmXn
 iXGN3AFE7THZt6qIYKmqNawGoswPSgpVfOD953kict+xZH3R5l8IJic3d4nZYPkYQn3nO0BEq
 4DlevSOlSCpFdd4yNVTiLK0lyMukQ3MuK8UxaA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

gcc points out some obviously broken code in linux-next

mm/vmalloc.c: In function 'pcpu_get_vm_areas':
mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    insert_vmap_area_augment(lva, &va->rb_node,
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     &free_vmap_area_root, &free_vmap_area_list);
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/vmalloc.c:916:20: note: 'lva' was declared here
  struct vmap_area *lva;
                    ^~~

Remove the obviously broken code. This is almost certainly
not the correct solution, but it's what I have applied locally
to get a clean build again.

Please fix this properly.

Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/vmalloc.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a9213fc3802d..bfcf0124a773 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -984,14 +984,9 @@ adjust_va_to_fit_type(struct vmap_area *va,
 		return -1;
 	}
 
-	if (type != FL_FIT_TYPE) {
+	if (type == FL_FIT_TYPE)
 		augment_tree_propagate_from(va);
 
-		if (type == NE_FIT_TYPE)
-			insert_vmap_area_augment(lva, &va->rb_node,
-				&free_vmap_area_root, &free_vmap_area_list);
-	}
-
 	return 0;
 }
 
-- 
2.20.0

