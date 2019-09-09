Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAB1DC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:42:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 723B12086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:42:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 723B12086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17EE6B0003; Mon,  9 Sep 2019 16:42:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7AE6B0006; Mon,  9 Sep 2019 16:42:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B03FA6B0007; Mon,  9 Sep 2019 16:42:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 88E9F6B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:42:10 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 33D0B180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:42:10 +0000 (UTC)
X-FDA: 75916554420.21.men71_6a2b4db52982a
X-HE-Tag: men71_6a2b4db52982a
X-Filterd-Recvd-Size: 3445
Received: from mout.kundenserver.de (mout.kundenserver.de [217.72.192.75])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:42:09 +0000 (UTC)
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1MQ5aw-1hlTmW3fuq-00M5vK; Mon, 09 Sep 2019 22:42:05 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Bernard Metzler <bmt@zurich.ibm.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: add dummy can_do_mlock() helper
Date: Mon,  9 Sep 2019 22:41:40 +0200
Message-Id: <20190909204201.931830-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
X-Provags-ID: V03:K1:NMgxzMZvNg4wYSfExpvmPgKHwnZ0vKKpKYsDNKfr1gaPuEOGj13
 9spfXcxohF5+owmMJ9nammIJCCQiu7DMpfXvuT2coJGiGarzO6vb/d3lF1fiLXjkdyRuL7M
 tOCQm7mRyhjjH61yIGaillDR5bdbqL0qWLgzJzWUMrVI0NVSW5RZF6brCLUjDNp06qKNCG5
 AiUHc8vd8nnf6RnUW6KSg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:e9wc4PuIlN8=:VQHamnwdDmOvm/t4sXsE4K
 rFPAvU6xvFooY2/BKW+q0CLtqQf4ht8iY6czqafmpju4onzJuZ7IQSatMoHAJYgqmI2TB+ZCM
 B8L0UDhX5J8JjL9khFaDkn/txs8rMFW6Mn/8sLWKz7PtYrHt+4BFO4b08zwzMm3xa1itXbzeX
 hYaBO7eNdiw92POSkthjxYpJwGeL596Z0fRcjczrM1pkOU9cIKkrI4Db+Ut2schd8k4n8NBRm
 IJGnm0qpCFT3T4Y7dwaJNSV3G06nxWpuex2MpCyKLycwLNnQdEmreptjIvQ3lapztT0TPCdJG
 f3Z2vt45S6MzHt9ueOqep8VNzKJoCFBei6oo6a5bASDfldb2rFnjdV1IndtVa8/qDiBdePISs
 uH2nwA2yI7tNl50aNnVQyEvoYqyFMIcIxdHzNHCveSz6kqZlpKllRJGH2MJIF/RP0OV8ldsTh
 6KiRzEGwHm+QakSYpHSXlsNJkywC2R/kni9Me5LPxdG1h+jFXIar+YWb1Zx5JNmjvohRHzWYY
 Dgpe3/RHod2rQ0l3dgqXd1P0OWKb4EhuNbeWxILBuD73L2pu1Eh2Hs1YpRxmv+i1dmaslP83p
 koFevhO1UWPRbckA4ZxUkZOHLLWJtUilwTgKgtdCnllLQPjnFHsfQ4yv7mZzwpO5XziAZSWDz
 lg29yZOQyABLlNLZxpohs4FYc/FuKdHlS9jDFuh/425QhrYxkTWZpdZ/+iKxY2wpRcTDFRndL
 CnezSza2f0Np3nj3lo/SPBgwR3zs4sn2A/AkHDkoOIuw/OGkv7mPODwbd8l6mKxbuKiv/SZ0e
 RO3slh3ultmVdWp3eD8T31Z2dLgLVAY5FuUz5UqLV9e7exCahI=
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On kernels without CONFIG_MMU, we get a link error for the siw
driver:

drivers/infiniband/sw/siw/siw_mem.o: In function `siw_umem_get':
siw_mem.c:(.text+0x4c8): undefined reference to `can_do_mlock'

This is probably not the only driver that needs the function
and could otherwise build correctly without CONFIG_MMU, so
add a dummy variant that always returns false.

Fixes: 2251334dcac9 ("rdma/siw: application buffer management")
Suggested-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66f296181bcc..cc292273e6ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1424,7 +1424,11 @@ extern void pagefault_out_of_memory(void);
=20
 extern void show_free_areas(unsigned int flags, nodemask_t *nodemask);
=20
+#ifdef CONFIG_MMU
 extern bool can_do_mlock(void);
+#else
+static inline bool can_do_mlock(void) { return false; }
+#endif
 extern int user_shm_lock(size_t, struct user_struct *);
 extern void user_shm_unlock(size_t, struct user_struct *);
=20
--=20
2.20.0


