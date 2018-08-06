Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3CC6B0272
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 12:41:08 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e3-v6so11295441wrr.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 09:41:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k15-v6sor4458971wrm.34.2018.08.06.09.41.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 09:41:07 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v5 09/10] arm64: update Documentation/arm64/tagged-pointers.txt
Date: Mon,  6 Aug 2018 18:40:44 +0200
Message-Id: <5396af31a51aaafd5d65742d1cc48854513be778.1533573460.git.andreyknvl@google.com>
In-Reply-To: <cover.1533573460.git.andreyknvl@google.com>
References: <cover.1533573460.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

Add a note that work on passing tagged user pointers to the kernel via
syscalls has started, but might not be complete yet.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 Documentation/arm64/tagged-pointers.txt | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
index a25a99e82bb1..361481283f00 100644
--- a/Documentation/arm64/tagged-pointers.txt
+++ b/Documentation/arm64/tagged-pointers.txt
@@ -35,8 +35,9 @@ Using non-zero address tags in any of these locations may result in an
 error code being returned, a (fatal) signal being raised, or other modes
 of failure.
 
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
+Some initial work for supporting non-zero address tags passed to the
+kernel via system calls has been done, but the kernel doesn't provide
+any guarantees at this point. Using a non-zero address tag for sp is
 strongly discouraged.
 
 Programs maintaining a frame pointer and frame records that use non-zero
-- 
2.18.0.597.ga71716f1ad-goog
