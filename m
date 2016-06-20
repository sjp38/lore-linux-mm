Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9CB86B025E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 14:33:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so29235002lfa.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:33:50 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id v1si30940154wjf.165.2016.06.20.11.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 11:33:44 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a66so10997631wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:33:44 -0700 (PDT)
Date: Mon, 20 Jun 2016 20:40:24 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v4 1/4] Add support for passing gcc plugin arguments
Message-Id: <20160620204024.e7847514bafbe3b2c58dfa67@gmail.com>
In-Reply-To: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
References: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net


Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 scripts/Makefile.gcc-plugins | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/Makefile.gcc-plugins b/scripts/Makefile.gcc-plugins
index 5e22b60..da7f86c 100644
--- a/scripts/Makefile.gcc-plugins
+++ b/scripts/Makefile.gcc-plugins
@@ -19,7 +19,7 @@ ifdef CONFIG_GCC_PLUGINS
     endif
   endif
 
-  GCC_PLUGINS_CFLAGS := $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y))
+  GCC_PLUGINS_CFLAGS := $(strip $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y)) $(gcc-plugin-cflags-y))
 
   export PLUGINCC GCC_PLUGINS_CFLAGS GCC_PLUGIN SANCOV_PLUGIN
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
