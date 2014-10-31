Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4830228001C
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:40:53 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so7131317pab.5
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:40:52 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id kg10si2820997pad.184.2014.10.31.00.40.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 00:40:52 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 31 Oct 2014 15:40:46 +0800
Subject: [RFC] arm:remove clear_thread_flag(TIF_UPROBE)
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1827B@CNBJMBX05.corpusers.net>
References: <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

This patch remove clear_thread_flag(TIF_UPROBE) in do_work_pending(),
because uprobe_notify_resume() have do this.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/kernel/signal.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/arm/kernel/signal.c b/arch/arm/kernel/signal.c
index bd19834..ff598f0 100644
--- a/arch/arm/kernel/signal.c
+++ b/arch/arm/kernel/signal.c
@@ -591,10 +591,9 @@ do_work_pending(struct pt_regs *regs, unsigned int thr=
ead_flags, int syscall)
 					return restart;
 				}
 				syscall =3D 0;
-			} else if (thread_flags & _TIF_UPROBE) {
-				clear_thread_flag(TIF_UPROBE);
+			} else if (thread_flags & _TIF_UPROBE)
 				uprobe_notify_resume(regs);
-			} else {
+			else {
 				clear_thread_flag(TIF_NOTIFY_RESUME);
 				tracehook_notify_resume(regs);
 			}
--=20
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
