Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2DF6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:45:23 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id g73so92217645ioe.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:45:23 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0106.hostedemail.com. [216.40.44.106])
        by mx.google.com with ESMTPS id d4si23953013iod.35.2016.01.29.06.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 06:45:23 -0800 (PST)
Date: Fri, 29 Jan 2016 09:45:20 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1 4/8] arch, ftrace: For KASAN put hard/soft IRQ
 entries into separate sections
Message-ID: <20160129094520.274a860f@gandalf.local.home>
In-Reply-To: <CAG_fn=V0-mAPiHS35JJMfrNgB2TFLiGwdbo4S1P_Pw_XR0sETw@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<99939a92dd93dc5856c4ec7bf32dbe0035cdc689.1453918525.git.glider@google.com>
	<20160128095349.6f771f14@gandalf.local.home>
	<CAG_fn=Ujxs6bv7ovPuOEtwRQGVSe-c3N3pGvWPHA_4oF3zqbFA@mail.gmail.com>
	<CAG_fn=V0-mAPiHS35JJMfrNgB2TFLiGwdbo4S1P_Pw_XR0sETw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Jan 2016 12:59:13 +0100
Alexander Potapenko <glider@google.com> wrote:

> On the other hand, this will require including <linux/irq.h> into
> various files that currently use __irq_section.
> But that header has a comment saying:
> 
> /*
>  * Please do not include this file in generic code.  There is currently
>  * no requirement for any architecture to implement anything held
>  * within this file.
>  *
>  * Thanks. --rmk
>  */
> 
> Do we really want to put anything into that header?
> 

What about interrupt.h?

It's just weird to have KSAN needing to pull in ftrace.h for irq work.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
