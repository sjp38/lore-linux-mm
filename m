Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5FD6B006C
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 12:06:14 -0500 (EST)
Received: by mail-ve0-f179.google.com with SMTP id jx11so11469588veb.10
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 09:06:13 -0800 (PST)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id t4si3861711vcz.133.2014.02.16.09.06.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 09:06:13 -0800 (PST)
Received: by mail-vc0-f176.google.com with SMTP id la4so10624378vcb.7
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 09:06:12 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 16 Feb 2014 19:06:12 +0200
Message-ID: <CA+ydwtp0MiXFwKL5u-mByvUngpzqp_dLyW8JkBNbvF2NG-aiKg@mail.gmail.com>
Subject: BUG: Bad rss-counter state mm:ffff88005f936c00 idx:0 val:1
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,

Noticed the following kernel message while fuzzing
3.14.0-rc2-00488-gca03339 with trinity. Should I be worried?

[40879.796336] BUG: Bad rss-counter state mm:ffff88005f936c00 idx:0 val:1

Tommi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
