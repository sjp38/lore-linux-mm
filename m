Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id DBAAA6B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 10:14:01 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so82869277pdb.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 07:14:01 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dz4si7254296pab.215.2015.05.08.07.07.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 07:07:34 -0700 (PDT)
Message-ID: <554CC31F.9050509@parallels.com>
Date: Fri, 8 May 2015 17:07:27 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH] UserfaultFD: Fix stack corruption when zeroing uffd_msg
References: <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com> <55425A74.3020604@parallels.com> <20150507134236.GB13098@redhat.com> <554B769E.1040000@parallels.com> <20150507143343.GG13098@redhat.com> <554B79C0.5060807@parallels.com> <20150507151136.GH13098@redhat.com> <554B82D4.4060809@parallels.com> <20150507170802.GI13098@redhat.com> <554CBC99.2050808@parallels.com>
In-Reply-To: <554CBC99.2050808@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>


Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 026ef99..c89e96f 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -134,7 +134,7 @@ static inline void msg_init(struct uffd_msg *msg)
 	 * Must use memset to zero out the paddings or kernel data is
 	 * leaked to userland.
 	 */
-	memset(&msg, 0, sizeof(struct uffd_msg));
+	memset(msg, 0, sizeof(struct uffd_msg));
 }
 
 static inline struct uffd_msg userfault_msg(unsigned long address,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
