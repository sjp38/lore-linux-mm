Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 778216B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:56:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c4-v6so10544701plz.20
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:56:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z29-v6si2529406pfl.209.2018.10.12.15.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 15:56:43 -0700 (PDT)
Date: Fri, 12 Oct 2018 15:56:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 201377] New: Kernel BUG under memory pressure: unable to
 handle kernel NULL pointer dereference at 00000000000000f0
Message-Id: <20181012155641.b3a1610b4ddcd37e374115d4@linux-foundation.org>
In-Reply-To: <20181012155533.2f15a8bb35103aa1fa87962e@linux-foundation.org>
References: <bug-201377-27@https.bugzilla.kernel.org/>
	<20181012155533.2f15a8bb35103aa1fa87962e@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, bugzilla-daemon@bugzilla.kernel.org, leozinho29_eu@hotmail.com
Cc: linux-mm@kvack.org

(cc linux-mm, argh)

On Fri, 12 Oct 2018 15:55:33 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> Vlastimil, it looks like your August 21 smaps changes are failing. 
> This one is pretty urgent, please.
> 
> Leonardo (yes?): thanks for reporting.  Very helpful.
> 
> On Thu, 11 Oct 2018 18:13:31 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=201377
> > 
> >             Bug ID: 201377
> >            Summary: Kernel BUG under memory pressure: unable to handle
> >                     kernel NULL pointer dereference at 00000000000000f0
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.19-rc7
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: leozinho29_eu@hotmail.com
> >         Regression: No
> > 
> > Created attachment 278997
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=278997&action=edit
> > dmesg and kernel config
> > 
> > I'm using Xubuntu 18.04 and I noticed that under memory pressure the script
> > from https://github.com/pixelb/ps_mem.git (HEAD
> > 1ed0bc5519d889d58235f2c35db01e4ede0d8231is) causing a kernel BUG and locking a
> > CPU. On dmesg the following appears:
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000f0
> > 
> > After this BUG the computer performance becomes greatly degraded, some software
> > do not close, some fail to open, some fail to work properly. As an example,
> > bash fails to autocomplete.
> > 
> > Steps to reproduce:
> > 
> > 1) Be under memory pressure. Using dd to write a large file at /dev/shm works
> > for this;
> > 2) Run the script from https://github.com/pixelb/ps_mem.git
> > 
> > Expected result: script will print information and system will keep working
> > normally;
> > 
> > Observed result: script is killed, kernel BUG happens, CPU get stuck and
> > computer presents problems.
> > 
> > I did not observe this with 4.17.19, I'll bisect and see if I can find which
> > commit is causing this.
> > 
> > I'm sorry if I'm reporting to the wrong product and component.
> > 
> > -- 
> > You are receiving this mail because:
> > You are the assignee for the bug.
