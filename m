Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 083486B000A
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:55:29 -0500 (EST)
Received: by mail-ia0-f174.google.com with SMTP id o25so4435795iad.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 13:55:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <510AE763.6090907@zytor.com>
References: <20130131005616.1C79F411@kernel.stglabs.ibm.com>
	<510AE763.6090907@zytor.com>
Date: Thu, 31 Jan 2013 13:55:29 -0800
Message-ID: <CAE9FiQVn6_QZi3fNQ-JHYiR-7jeDJ5hT0SyT_+zVvfOj=PzF3w@mail.gmail.com>
Subject: Re: [RFC][PATCH] rip out x86_32 NUMA remapping code
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 31, 2013 at 1:51 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> I get a build failure on i386 allyesconfig with this patch:
>
> arch/x86/power/built-in.o: In function `swsusp_arch_resume':
> (.text+0x14e4): undefined reference to `resume_map_numa_kva'
>
> It looks trivial to fix up; I assume resume_map_numa_kva() just goes
> away like it does in the non-NUMA case, but it would be nice if you
> could confirm that.

the patches does not seem to complete.

at least, it does not remove

arch/x86/mm/numa.c:     nd = alloc_remap(nid, nd_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
