Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 497606B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 20:53:00 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v63so1648618oif.7
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 17:53:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j45si4222245ota.135.2017.12.03.17.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 17:52:59 -0800 (PST)
Date: Mon, 4 Dec 2017 09:52:54 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171204015254.GG15074@x1>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
 <20171201151851.GK2198@x1>
 <20171201152710.z2nushke5paoqhxc@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201152710.z2nushke5paoqhxc@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, dave.hansen@linux.intel.com, hughd@google.com, luto@kernel.org

On 12/01/17 at 04:27pm, Borislav Petkov wrote:
> On Fri, Dec 01, 2017 at 11:18:51PM +0800, Baoquan He wrote:
> > On 12/01/17 at 02:52pm, Juerg Haefliger wrote:
> > > Loading a kexec kernel using today's linux-tip master with KAISER=y
> > > triggers the following warning:
> > 
> > I also noticed this when trigger a crash to jump to kdump kernel, and
> > kdump kernel failed to bootup. I am trying to fix it on tip/WIP.x86/mm.
> > Maybe still need a little time.
> 
> Save yourself the energy, the WARN is wrong there and wil go away.

OK, will test patch.

> -- 
> 
> Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
