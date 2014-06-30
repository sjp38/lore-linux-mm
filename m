Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 351106B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:52:10 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so7427343ier.40
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 15:52:09 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id w9si31682264icy.8.2014.06.30.15.52.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 15:52:09 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so4872698igd.14
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 15:52:08 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:52:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] binfmt_elf.c: use get_random_int() to fix entropy depleting
 fix
In-Reply-To: <20140626074735.GA24582@localhost>
Message-ID: <alpine.DEB.2.02.1406301549020.23648@chino.kir.corp.google.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com> <20140625100213.GA1866@localhost> <53AAB2D3.2050809@oracle.com> <alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com> <53AB7F0B.5050900@oracle.com> <alpine.DEB.2.02.1406252310560.3960@chino.kir.corp.google.com>
 <53ABBEA0.1010307@oracle.com> <20140626074735.GA24582@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jeff Liu <jeff.liu@oracle.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org

The type of size_t on am33 is unsigned int for gcc major versions >= 4.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/binfmt_elf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -155,7 +155,7 @@ static void get_atrandom_bytes(unsigned char *buf, size_t nbytes)
 
 	while (nbytes) {
 		unsigned int random_variable;
-		size_t chunk = min(nbytes, sizeof(random_variable));
+		size_t chunk = min(nbytes, (size_t)sizeof(random_variable));
 
 		random_variable = get_random_int();
 		memcpy(p, &random_variable, chunk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
