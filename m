Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ACE4D900015
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 06:27:42 -0400 (EDT)
Received: by wghl18 with SMTP id l18so26561095wgh.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 03:27:42 -0700 (PDT)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id kc1si34538413wjc.145.2015.03.09.03.27.34
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 03:27:34 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 5/6] Kconfig: memtest: update number of test patterns up to 17
Date: Mon,  9 Mar 2015 10:27:09 +0000
Message-Id: <1425896830-19705-6-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org, baruch@tkos.co.il, rdunlap@infradead.org

Additional test patterns for memtest were introduced since 63823126
"x86: memtest: add additional (regular) test patterns", but looks like
Kconfig was not updated that time.

Update Kconfig entry with the actual number of maximum test patterns.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 lib/Kconfig.debug |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8eb064fd..2832b0e 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1740,7 +1740,7 @@ config MEMTEST
 =09        memtest=3D0, mean disabled; -- default
 =09        memtest=3D1, mean do 1 test pattern;
 =09        ...
-=09        memtest=3D4, mean do 4 test patterns.
+=09        memtest=3D17, mean do 17 test patterns.
 =09  If you are unsure how to answer this question, answer N.
=20
 source "samples/Kconfig"
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
