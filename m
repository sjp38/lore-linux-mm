Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBAF6B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 10:00:34 -0500 (EST)
Received: by pdjp10 with SMTP id p10so14510517pdj.3
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 07:00:33 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id uw6si5258364pac.59.2015.02.21.07.00.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Feb 2015 07:00:32 -0800 (PST)
Message-ID: <1424530825.6539.7.camel@stgolabs.net>
Subject: Re: [PATCH 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sat, 21 Feb 2015 07:00:25 -0800
In-Reply-To: <CAHC9VhQxi3YNPFvmfMS6aceC=mi_LcaLD6gqb2zKEb8K_qnZLQ@mail.gmail.com>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-2-git-send-email-dbueso@suse.de>
	 <CAHC9VhR212FmSEhV_2yryt0=YxTN34ktZ8vveBD3kv4Uhd4WTw@mail.gmail.com>
	 <1424481838.6539.2.camel@stgolabs.net>
	 <CAHC9VhQxi3YNPFvmfMS6aceC=mi_LcaLD6gqb2zKEb8K_qnZLQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-audit@redhat.com

On Sat, 2015-02-21 at 08:45 -0500, Paul Moore wrote:
> On Fri, Feb 20, 2015 at 8:23 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> > On Wed, 2015-02-18 at 22:23 -0500, Paul Moore wrote:
> >> I'd prefer if the audit_log_d_path_exe() helper wasn't a static inline.
> >
> > What do you have in mind?
> 
> Pretty much what I said before, audit_log_d_path_exe() as a
> traditional function and not an inline.  Put the function in
> kernel/audit.c.

well yes I know that, which is why I showed you the code sizes. Now
again, do you have any reason? This function will only get less bulky in
the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
