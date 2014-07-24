Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id D7D486B0037
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:50:56 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id el20so2160824lab.27
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:55 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id uq9si13810412lac.25.2014.07.24.09.50.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 09:50:53 -0700 (PDT)
Received: by mail-lb0-f169.google.com with SMTP id s7so2525989lbd.0
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:53 -0700 (PDT)
Message-Id: <20140724164657.452106845@openvz.org>
Date: Thu, 24 Jul 2014 20:46:57 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 0/4] prctl: set-mm -- Rework interface, v2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gorcunov@openvz.org, keescook@chromium.org, tj@kernel.org, akpm@linux-foundation.org, avagin@openvz.org, ebiederm@xmission.com, hpa@zytor.com, serge.hallyn@canonical.com, xemul@parallels.com, segoon@openwall.com, kamezawa.hiroyu@jp.fujitsu.com, mtk.manpages@gmail.com, jln@google.com

  Hi, here is a second version. I've tried to address all comments
(for which I'm really grateful). I believe the main question which
remains opened is exe-fd setup. Hopefully the current limitation
(root only) would be enough.

Also, Julien, there is no additional need for ordering test of
@start_stack member since we use find_vma helper.

Please take a look, once you have a spare minutes, thanks!

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
