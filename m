Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEDA98E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 19:14:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so20911228qte.0
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 16:14:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor19419649qkl.81.2019.01.12.16.14.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 16:14:52 -0800 (PST)
From: Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH -manpage 0/2] Document memfd F_SEAL_FUTURE_WRITE seal
Date: Sat, 12 Jan 2019 19:14:44 -0500
Message-Id: <20190113001446.158789-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mtk.manpages@gmail.com
Cc: Joel Fernandes <joel@joelfernandes.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, dancol@google.com, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, linux-api@vger.kernel.org, linux-man@vger.kernel.org, linux-mm@kvack.org, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Hello,

These manpages correspond to the following kernel patches:
https://lore.kernel.org/patchwork/patch/1031550/
https://lore.kernel.org/patchwork/patch/1031551/

This is just a resend with no changes from last time.

Joel Fernandes (Google) (2):
fcntl.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
memfd_create.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal

man2/fcntl.2        | 15 +++++++++++++++
man2/memfd_create.2 | 15 ++++++++++++++-
2 files changed, 29 insertions(+), 1 deletion(-)

--
2.20.1.97.g81188d93c3-goog
