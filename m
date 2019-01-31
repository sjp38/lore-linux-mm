Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 840BAC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4216B218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h5nOl1Zr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4216B218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5CE18E0004; Thu, 31 Jan 2019 11:25:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2338E0003; Thu, 31 Jan 2019 11:25:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C478E0004; Thu, 31 Jan 2019 11:25:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 443938E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:25:03 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g92-v6so609989ljg.23
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:25:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=LikxHqRWe3hjXCb7z4Z2tQt/qnU/bnpFMlaXM+BoVok=;
        b=aOtcJHB2nbhm76txUUTPfTdAqMQbfzuuoKxDYZoEMWAhiRpqA86ASglRj6qE7go7tS
         PKPbagQ+R4HVm8DY0EOy92ZXfdzKVlitvn3z/tPuSC/UXC5slvs+u5r07X8ZLcSQd23M
         asjpInQAu7/ASr2RIHkpYUj3eUVfwEbc+e0ArnkOEY6hCsTDHAhSqFKJeERsPJk32c/h
         aOxMb/gZ2z1VXVfjQATVxWo7pG1p8Vgw2auG//tpj4HZBgyfGg0eCU/bd/3+nvqDzJ/1
         JZFeqzBdry3dLAblaql4XsyhWDLsRvtijVl8mDNdzfyKXvaCOYrTlQSd8ST0mWFwsa8H
         jX2Q==
X-Gm-Message-State: AJcUukeZnT3ywWzNsSaW5aYH59am+z2YW4fdmXIbAmPei8GTpy0UPMJA
	tfbszBEf//IKTZjgUc9rtvEZZ1yE8Fa5EQU3sPdsOSFmzxO5eEF/f25iSFAF9J45ujXlVu4CSD0
	MqY5FFNNMQOWXWB7ZIrbjjNLahTUHtj3lmg4QmlhcOIO5NUU2VecJin3Xlw2O6Fa9enVfdlRYmk
	1ghlhQLJ7TpSfff5zpjwGmEPHBEm7JFIJ+nj+vtjfca9C2q/vwb64xVSM+Mz/NT9Qypd/shr54Q
	4rD8NaRsNv3H//0pwoBim0G9FWPRC0p9OFYRC32T5s/zdVCFP9HSUlNCkpJSMbAP3IgkyLaocpp
	TdLnaIZbBeenf88O3r+zOq0H99RLYCSqJSD/lFcQjIG5pyqetAmGIcdTArw7tt4d96Sjh9K0YFW
	p
X-Received: by 2002:a2e:8605:: with SMTP id a5-v6mr27931838lji.145.1548951902611;
        Thu, 31 Jan 2019 08:25:02 -0800 (PST)
X-Received: by 2002:a2e:8605:: with SMTP id a5-v6mr27931767lji.145.1548951901312;
        Thu, 31 Jan 2019 08:25:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548951901; cv=none;
        d=google.com; s=arc-20160816;
        b=VyRKKnjw3tl1yKAR6eRM6SiSMfVueO12OqyaRcEvD9Ky6Uc4peOK//Sf1sOtiiEblW
         OUqAh60fgJT70v0Srf5GdSV4LJachF7RCze0kBnjKkjQDMmXJnmReh4Erpyw5F1Lu718
         LLB47PY5vq82INmWS970gHGVEvAj8PllH/kfpkNrG3RGN0yOVYu6Bxf/2IN45kfAbOFi
         SyNorGg+AmT8hK780Y3Nkjf4Xj2xS3ZV9hvgkQ2wM18h/RUOcV/g+OsMOm4+HvOGsH4I
         TyA48GYawf2gDyGqxfubmap1WnwujPj5zya6f8skWHTm5GT/gcVGsRu1/JBTCo4P/vyX
         UxBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=LikxHqRWe3hjXCb7z4Z2tQt/qnU/bnpFMlaXM+BoVok=;
        b=fl1z+oZqiRoc7YKWzDv2MT4b33wkn2kiXTtdxPIN/EyIHRobkPgqDgwXfoP94iidMx
         N3LOg5/gVu29bYHyLwG5h2HHlURCgWBX/GuUCfHJYn46etE/x8k4U5KicimWKeNzopYI
         UAK++IOFL33OinQadxibluYftYzOqMXZQvROkDEwcPpFaz/+fnq2QbYcO+LbCpZwxJ5s
         HW8klFxAvcfTSQ+Nu30uT158fZ+Gos6n+qy+8BOqUvZhWGhoEnBFLiH9/rLVNee9JTqh
         zE2c9daU6/X0vCXfuK0iCZevdKRuVcxe+0H2zidsgh1/d8LFtlWOnFFiU7SKPKJkcGUn
         q8rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h5nOl1Zr;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2-v6sor3528081lje.12.2019.01.31.08.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 08:25:01 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h5nOl1Zr;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=LikxHqRWe3hjXCb7z4Z2tQt/qnU/bnpFMlaXM+BoVok=;
        b=h5nOl1ZrqIDtZT5ELvlIWlWxX+VkQQvGj/ENOOkAh/20HMnikuTXkdjru37zdjcEj7
         7CakwLLnjlv5QJU7GhUSlyoMVxgaC5mBVPZ7R1WPCCi7EPZYy4ghniGfVUiBgMYc9pTw
         Om7nUSB8n39h31aqjbPLyn11T4LGTvfiWQuozCFMj9+2Jb/D8pAZhcUzfw7XrJtY6CTY
         bI6zK0lb4Oqv17oktO9wQoufGW6XgKJ/4MKcUZi4JdjEnVb4PiteH67JppZ4ytY1rowE
         vawQeP/J6oIdRUSaFFNEC+zVfHMav8WK4+peikRgXU/Tsdzdou4VREKoMstoQmRu17Fd
         wO0A==
X-Google-Smtp-Source: AHgI3IZHJRUGTh6+ZKgbU+SIwrVuiqL06s4+JNKdmR3XYq04b0qpQWQVV7+Dec7XRQKI99eaQXEXmQ==
X-Received: by 2002:a2e:8446:: with SMTP id u6-v6mr16709416ljh.74.1548951900903;
        Thu, 31 Jan 2019 08:25:00 -0800 (PST)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z6sm909595lfd.50.2019.01.31.08.24.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 08:25:00 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
Date: Thu, 31 Jan 2019 17:24:52 +0100
Message-Id: <20190131162452.25879-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
value on both 32 and 64 bit systems. lazy_max_pages() deals with
"unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
should be 8 bytes on 64 bit as well.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index abe83f885069..755b02983d8d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -632,7 +632,7 @@ static unsigned long lazy_max_pages(void)
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
 }
 
-static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
+static atomic_long_t vmap_lazy_nr = ATOMIC_LONG_INIT(0);
 
 /*
  * Serialize vmap purging.  There is no actual criticial section protected
@@ -650,7 +650,7 @@ static void purge_fragmented_blocks_allcpus(void);
  */
 void set_iounmap_nonlazy(void)
 {
-	atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
+	atomic_long_set(&vmap_lazy_nr, lazy_max_pages()+1);
 }
 
 /*
@@ -658,10 +658,10 @@ void set_iounmap_nonlazy(void)
  */
 static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 {
+	unsigned long resched_threshold;
 	struct llist_node *valist;
 	struct vmap_area *va;
 	struct vmap_area *n_va;
-	int resched_threshold;
 
 	lockdep_assert_held(&vmap_purge_lock);
 
@@ -681,16 +681,16 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	}
 
 	flush_tlb_kernel_range(start, end);
-	resched_threshold = (int) lazy_max_pages() << 1;
+	resched_threshold = lazy_max_pages() << 1;
 
 	spin_lock(&vmap_area_lock);
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
-		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
+		unsigned long nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
 
 		__free_vmap_area(va);
-		atomic_sub(nr, &vmap_lazy_nr);
+		atomic_long_sub(nr, &vmap_lazy_nr);
 
-		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
+		if (atomic_long_read(&vmap_lazy_nr) < resched_threshold)
 			cond_resched_lock(&vmap_area_lock);
 	}
 	spin_unlock(&vmap_area_lock);
@@ -727,10 +727,10 @@ static void purge_vmap_area_lazy(void)
  */
 static void free_vmap_area_noflush(struct vmap_area *va)
 {
-	int nr_lazy;
+	unsigned long nr_lazy;
 
-	nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
-				    &vmap_lazy_nr);
+	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
+				PAGE_SHIFT, &vmap_lazy_nr);
 
 	/* After this point, we may free va at any time */
 	llist_add(&va->purge_list, &vmap_purge_list);
-- 
2.11.0

