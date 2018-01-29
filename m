Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6855D6B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:31:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 17so19659370wma.1
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:31:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x72si8167308wrb.81.2018.01.29.05.31.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 05:31:55 -0800 (PST)
Date: Mon, 29 Jan 2018 14:31:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: migrate_pages() of process with same UID in 4.15-rcX
Message-ID: <20180129133151.GF21609@dhcp22.suse.cz>
References: <1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com>
 <87d12hbs6s.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d12hbs6s.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jan Stancek <jstancek@redhat.com>, otto ebeling <otto.ebeling@iki.fi>, mtk manpages <mtk.manpages@gmail.com>, linux-mm@kvack.org, clameter@sgi.com, w@1wt.eu, keescook@chromium.org, ltp@lists.linux.it, Linus Torvalds <torvalds@linux-foundation.org>

[Sorry for a very late reply]

On Wed 10-01-18 10:21:31, Eric W. Biederman wrote:
[...]
> All of that said.  I am wondering if we should have used
> PTRACE_MODE_READ_FSCREDS on these permission checks.

If this is really about preventing the layout discovery then we should
be in sync with proc_mem_open and that uses PTRACE_MODE_FSCREDS|PTRACE_MODE_READ
Should we do the same thing here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
