Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B703A6B025E
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:27:20 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 11so5893469wrb.18
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:27:20 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id c10si5315901wrg.214.2017.12.01.07.27.19
        for <linux-mm@kvack.org>;
        Fri, 01 Dec 2017 07:27:19 -0800 (PST)
Date: Fri, 1 Dec 2017 16:27:10 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171201152710.z2nushke5paoqhxc@pd.tnic>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
 <20171201151851.GK2198@x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171201151851.GK2198@x1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, dave.hansen@linux.intel.com, hughd@google.com, luto@kernel.org

On Fri, Dec 01, 2017 at 11:18:51PM +0800, Baoquan He wrote:
> On 12/01/17 at 02:52pm, Juerg Haefliger wrote:
> > Loading a kexec kernel using today's linux-tip master with KAISER=y
> > triggers the following warning:
> 
> I also noticed this when trigger a crash to jump to kdump kernel, and
> kdump kernel failed to bootup. I am trying to fix it on tip/WIP.x86/mm.
> Maybe still need a little time.

Save yourself the energy, the WARN is wrong there and wil go away.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
