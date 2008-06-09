From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] Re: 2.6.26-rc5-mm1 - fix parenthesis in drivers/net/smc911x.h
Date: Mon, 9 Jun 2008 21:20:02 +0200
References: <20080609053908.8021a635.akpm@linux-foundation.org>
In-Reply-To: <20080609053908.8021a635.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806092120.02943.m.kozlowski@tuxland.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Parenthesis fix in drivers/net/smc911x.h

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

--- linux-2.6.26-rc5-mm1-a/drivers/net/smc911x.h	2008-06-09 19:22:02.000000000 +0200
+++ linux-2.6.26-rc5-mm1-b/drivers/net/smc911x.h	2008-06-09 19:24:57.000000000 +0200
@@ -177,7 +177,7 @@ static inline void SMC_outsl(struct smc9
 }
 #else
 #if	SMC_USE_16BIT
-#define SMC_inl(lp, r)		 (readw((lp)->base + (r)) & 0xFFFF) + (readw((lp)->base + (r) + 2) << 16))
+#define SMC_inl(lp, r)		 ((readw((lp)->base + (r)) & 0xFFFF) + (readw((lp)->base + (r) + 2) << 16))
 #define SMC_outl(v, lp, r) 			 \
 	do{					 \
 		 writew(v & 0xFFFF, (lp)->base + (r));	 \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
