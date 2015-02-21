Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE296B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 08:45:45 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so29397385obc.4
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 05:45:44 -0800 (PST)
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com. [209.85.218.53])
        by mx.google.com with ESMTPS id sb4si2818905oeb.13.2015.02.21.05.45.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Feb 2015 05:45:44 -0800 (PST)
Received: by mail-oi0-f53.google.com with SMTP id u20so7029894oif.12
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 05:45:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424481838.6539.2.camel@stgolabs.net>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-2-git-send-email-dbueso@suse.de>
	<CAHC9VhR212FmSEhV_2yryt0=YxTN34ktZ8vveBD3kv4Uhd4WTw@mail.gmail.com>
	<1424481838.6539.2.camel@stgolabs.net>
Date: Sat, 21 Feb 2015 08:45:43 -0500
Message-ID: <CAHC9VhQxi3YNPFvmfMS6aceC=mi_LcaLD6gqb2zKEb8K_qnZLQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Paul Moore <paul@paul-moore.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-audit@redhat.com

On Fri, Feb 20, 2015 at 8:23 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> On Wed, 2015-02-18 at 22:23 -0500, Paul Moore wrote:
>> I'd prefer if the audit_log_d_path_exe() helper wasn't a static inline.
>
> What do you have in mind?

Pretty much what I said before, audit_log_d_path_exe() as a
traditional function and not an inline.  Put the function in
kernel/audit.c.

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
