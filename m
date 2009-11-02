Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43B416B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 12:08:14 -0500 (EST)
Received: by iwn5 with SMTP id 5so3486618iwn.11
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 09:08:12 -0800 (PST)
MIME-Version: 1.0
From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Date: Mon, 2 Nov 2009 09:07:52 -0800
Message-ID: <43e72e890911020907m7cfc48edpd300243de7af36ed@mail.gmail.com>
Subject: Kmemleak for mips
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: subscriptions@stroomer.com, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Curious what the limitations are on restricting kmemleak to non-mips
archs. I have a user and situation [1] where this could be helpful [1]
in debugging an issue. The user reports he cannot enable it on mips.

[1] http://bugzilla.kernel.org/show_bug.cgi?id=14502

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
