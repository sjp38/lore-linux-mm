Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9616B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:14:29 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id v1so9650725oia.9
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:14:29 -0800 (PST)
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com. [209.85.218.46])
        by mx.google.com with ESMTPS id 69si10219090oij.9.2015.02.22.05.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 05:14:28 -0800 (PST)
Received: by mail-oi0-f46.google.com with SMTP id x69so9614427oia.5
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:14:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424530825.6539.7.camel@stgolabs.net>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-2-git-send-email-dbueso@suse.de>
	<CAHC9VhR212FmSEhV_2yryt0=YxTN34ktZ8vveBD3kv4Uhd4WTw@mail.gmail.com>
	<1424481838.6539.2.camel@stgolabs.net>
	<CAHC9VhQxi3YNPFvmfMS6aceC=mi_LcaLD6gqb2zKEb8K_qnZLQ@mail.gmail.com>
	<1424530825.6539.7.camel@stgolabs.net>
Date: Sun, 22 Feb 2015 08:14:28 -0500
Message-ID: <CAHC9VhRPFcEYN7gfMVbVtnQgn=JhXiWiFe4__AHqaC9pqGfUPw@mail.gmail.com>
Subject: Re: [PATCH 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Paul Moore <paul@paul-moore.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-audit@redhat.com

On Sat, Feb 21, 2015 at 10:00 AM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> On Sat, 2015-02-21 at 08:45 -0500, Paul Moore wrote:
>> On Fri, Feb 20, 2015 at 8:23 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
>> > On Wed, 2015-02-18 at 22:23 -0500, Paul Moore wrote:
>> >> I'd prefer if the audit_log_d_path_exe() helper wasn't a static inline.
>> >
>> > What do you have in mind?
>>
>> Pretty much what I said before, audit_log_d_path_exe() as a
>> traditional function and not an inline.  Put the function in
>> kernel/audit.c.
>
> well yes I know that, which is why I showed you the code sizes. Now
> again, do you have any reason? This function will only get less bulky in
> the future.

The code size was pretty negligible from my point of view, not enough
to outweigh my preference for a non-inlined version of the function.
Also, I expect this function will be one of the things that gets
shuffled/reworked in the coming months as we make some architectural
changes to audit.

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
