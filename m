Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8176B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 02:10:18 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so7109361pdj.12
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:10:18 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sz8si7467610pac.181.2014.07.20.23.10.16
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 23:10:17 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v7 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER, PR_MPX_UNREGISTER
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
	<1405921124-4230-9-git-send-email-qiaowei.ren@intel.com>
Date: Sun, 20 Jul 2014 23:09:41 -0700
In-Reply-To: <1405921124-4230-9-git-send-email-qiaowei.ren@intel.com> (Qiaowei
	Ren's message of "Mon, 21 Jul 2014 13:38:42 +0800")
Message-ID: <87lhrn2qfu.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Qiaowei Ren <qiaowei.ren@intel.com> writes:

> This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
> commands. These commands can be used to register and unregister MPX
> related resource on the x86 platform.

Please provide a manpage for the API. This is needed
for proper review. Your description is far too vague.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
