Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED25D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:27:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m9so2214451wmd.0
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 23:27:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z16sor898281wrc.34.2017.11.22.23.27.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 23:27:45 -0800 (PST)
Date: Thu, 23 Nov 2017 08:27:42 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
Message-ID: <20171123072742.ouswjlvevpuincgx@gmail.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


32-bit x86 defconfig still doesn't build:

 arch/x86/events/intel/ds.c: In function a??dsalloca??:
 arch/x86/events/intel/ds.c:296:6: error: implicit declaration of function a??kaiser_add_mappinga??; did you mean a??kgid_has_mappinga??? [-Werror=implicit-function-declaration]

Also, could you please use proper subsystem tags, instead of:

  Subject: x86, kaiser: Disable global pages by default with KAISER

Please do something like:

  Subject: x86/mm/kaiser: Disable global pages by default with KAISER

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
