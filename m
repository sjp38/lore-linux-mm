Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD06BC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 671462183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 671462183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EB866B000D; Thu, 18 Apr 2019 05:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 055986B0010; Thu, 18 Apr 2019 05:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E32B06B0269; Thu, 18 Apr 2019 05:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF5A6B000D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:14 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x9so1502346wrw.20
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=QesvxAdhNbDpCrwGVxWTyn37DOC2nIpwHMLZVWagzF4=;
        b=lJnENKmEbWpN9ZtLJi4xJLdtmRhkGVOYv3BApZOaFGHu6XFcuMbN+eGK2+TXqU6oLn
         EqfeqQKecffwgyeSU6clyMuHknaSPv6VKMEvUfOshSUOYka2G0skiY+52xvHE70dc2dp
         XpXqbZ2i/h8EWOpLyFHx1SlJ/JvekzArGMVVrFWskebBGwDyPe0IXZ57YwlSvjA8zRCB
         2qczDBGpPFc4VMQaR98cS/OhcvZLZfruNvwxBe2Wqw2ut51Fbfe7wO3Ftumv+x3Cf1bH
         F7VmipoxnyvEHPSED1SckSqn2Vg7RosDKAZXByCOGDJ2C3cYdBKT4VVWZ/EDLZUSFEEX
         GoDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAX+Y1yGom0ArIN8MrkLgBekbV5ifye1xL7HEF0McOdWF4IFyfcU
	1fUR1GOInYdYqdV3VrBHKCt/7l7Y8TdDkPnjT6ZUQN1uY7IDSkWYEPe/hzsOsXRaxAgms9e45fz
	rY1pH/1WtuLqt4i5vB5ZPdMByjq5FzsbXxhk5Bhz/vqWjTnH7+2JdKbg6R8ZOmx3L1A==
X-Received: by 2002:a1c:3982:: with SMTP id g124mr2218467wma.25.1555578374115;
        Thu, 18 Apr 2019 02:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDq7p6N7QSldg1tjppEc4gvb8DlJPXdOsuRk1URbWt2ih7/Ih05xOzgQUdHYYNhc3RDUVg
X-Received: by 2002:a1c:3982:: with SMTP id g124mr2218416wma.25.1555578373271;
        Thu, 18 Apr 2019 02:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578373; cv=none;
        d=google.com; s=arc-20160816;
        b=R3kSlx5IsMfpdVX/m1Y7NckbcYruVTN4txdZmJTjKjmErHokpiT5lALO0dQzcjOsZ5
         2NkT6SqE99eRWSIMUuf1Wq518te85zfbsB3fWa7lWS9awekekGZJI9ZOwSSypErfbKTK
         dMJfYH3mJgyAIKyYGM1/MKM0gmzSnK2ZHrVS77mCHYat2fYHdrX4xLTlp6m8iNwLJls4
         1J2UlNLlo/xW7HcYaUvUgVnMkT1/Rih+HC+5fG9zHx7FqacRy4zjHqPLDUvFsOhNzkpk
         GyP518iuir0I9lCsOc/qlMqquXe7mF8lCM+bhtFVBtoHcKqe1duhpFPFwXCsqNi3QmcL
         VmRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=QesvxAdhNbDpCrwGVxWTyn37DOC2nIpwHMLZVWagzF4=;
        b=j8RYcufEO+732KIJLfL3JsfmB+ZBdAnWyqtsWQIFcTDpFwkjwN5rT2GCoT2GHBPFEd
         BBJDcSAXJD5MzzxbYfaHBqzq+LpHOME5o6B1qrcR+ce5CdVXOJX/2oswMbL8gZ5brlpm
         JwsoQ2PSl9J+ipqs4pHOuF1HOrDKxUgNgq+hy5nauEOU6uGUIK2ldBh15cZwDeZD0kV3
         Pes7VUsc6/ZlCgC7PLkWLa/tAGK0w2pAVRjS86UrU8jgNQWvVQRL1v5td0FM/7DZAG4p
         fvMHp34uySqu82aqrLEzAyMZWH819vPabj0dAT9Kv2/nXwmLj/4Ws9nHTdImajySbvgE
         2iRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l10si1083577wme.127.2019.04.18.02.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zh-0001mY-4r; Thu, 18 Apr 2019 11:06:09 +0200
Message-Id: <20190418084253.534580989@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:24 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 05/29] proc: Simplify task stack retrieval
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace with an invocation of
the storage array based interface.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/base.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -407,7 +407,6 @@ static void unlock_trace(struct task_str
 static int proc_pid_stack(struct seq_file *m, struct pid_namespace *ns,
 			  struct pid *pid, struct task_struct *task)
 {
-	struct stack_trace trace;
 	unsigned long *entries;
 	int err;
 
@@ -430,20 +429,17 @@ static int proc_pid_stack(struct seq_fil
 	if (!entries)
 		return -ENOMEM;
 
-	trace.nr_entries	= 0;
-	trace.max_entries	= MAX_STACK_TRACE_DEPTH;
-	trace.entries		= entries;
-	trace.skip		= 0;
-
 	err = lock_trace(task);
 	if (!err) {
-		unsigned int i;
+		unsigned int i, nr_entries;
 
-		save_stack_trace_tsk(task, &trace);
+		nr_entries = stack_trace_save_tsk(task, entries,
+						  MAX_STACK_TRACE_DEPTH, 0);
 
-		for (i = 0; i < trace.nr_entries; i++) {
+		for (i = 0; i < nr_entries; i++) {
 			seq_printf(m, "[<0>] %pB\n", (void *)entries[i]);
 		}
+
 		unlock_trace(task);
 	}
 	kfree(entries);


