Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 299C16B0253
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:12:40 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so1422514lbb.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:12:40 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id w123si986745wmd.120.2016.06.14.15.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 15:12:39 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id m124so1625771wme.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:12:38 -0700 (PDT)
Date: Wed, 15 Jun 2016 00:19:26 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v3 1/4] Add support for passing gcc plugin arguments
Message-Id: <20160615001926.74e2c18cbefe799b0a0c2dcb@gmail.com>
In-Reply-To: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
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
