Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 14AE46B0087
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:46:58 -0400 (EDT)
Date: Wed, 20 May 2009 11:47:13 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 2/5] Apply the PG_sensitive flag to mac80211 WEP key
	handling
Message-ID: <20090520184713.GB10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, linux-wireless@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch deploys the use of the PG_sensitive page allocator flag
within the mac80211 driver, more specifically the handling of WEP
RC4 keys during encryption and decryption.

Signed-off-by: Larry H. <research@subreption.com>

---
 net/mac80211/wep.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/net/mac80211/wep.c
===================================================================
--- linux-2.6.orig/net/mac80211/wep.c
+++ linux-2.6/net/mac80211/wep.c
@@ -155,7 +155,7 @@ int ieee80211_wep_encrypt(struct ieee802
 		return -1;
 
 	klen = 3 + key->conf.keylen;
-	rc4key = kmalloc(klen, GFP_ATOMIC);
+	rc4key = kmalloc(klen, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!rc4key)
 		return -1;
 
@@ -243,7 +243,7 @@ int ieee80211_wep_decrypt(struct ieee802
 
 	klen = 3 + key->conf.keylen;
 
-	rc4key = kmalloc(klen, GFP_ATOMIC);
+	rc4key = kmalloc(klen, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!rc4key)
 		return -1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
