Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6025B6B005A
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:27:24 -0400 (EDT)
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<4ABB6EB6.2040204@linux.vnet.ibm.com>
From: Dan Smith <danms@us.ibm.com>
Date: Thu, 24 Sep 2009 09:27:30 -0700
Message-ID: <878wg41f65.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rishikesh <risrajak@linux.vnet.ibm.com>
Cc: Oren Laadan <orenl@librato.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

R> I am getting following build error while compiling linux-cr kernel.

With CONFIG_CHECKPOINT=3Dn, right?

R> 76569 net/unix/af_unix.c:528: error: =E2=80=98unix_collect=E2=80=99 unde=
clared here (not=20
R> in a function)

Try the patch below.

--=20
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index e42a714..ee423d1 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -80,6 +80,7 @@ extern int unix_collect(struct ckpt_ctx *ctx, struct sock=
et *sock);
 #else
 #define unix_checkpoint NULL
 #define unix_restore NULL
+#define unix_collect NULL
 #endif /* CONFIG_CHECKPOINT */
=20
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
