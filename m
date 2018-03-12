Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5A96B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 05:47:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p202-v6so5146856lfe.3
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 02:47:19 -0700 (PDT)
Received: from mail.kapsi.fi (mail.kapsi.fi. [2001:67c:1be8::25])
        by mx.google.com with ESMTPS id r68si2587893ljb.247.2018.03.12.02.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 02:47:17 -0700 (PDT)
Date: Mon, 12 Mar 2018 11:46:44 +0200 (EET)
From: Otto Ebeling <otto.ebeling@iki.fi>
In-Reply-To: <20180129135747.GG21609@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1803121143440.19708@lakka.kapsi.fi>
References: <1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com> <87d12hbs6s.fsf@xmission.com> <20180129133151.GF21609@dhcp22.suse.cz> <20180129135747.GG21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Subject: Re: migrate_pages() of process with same UID in 4.15-rcX
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Jan Stancek <jstancek@redhat.com>, otto ebeling <otto.ebeling@iki.fi>, mtk manpages <mtk.manpages@gmail.com>, linux-mm@kvack.org, w@1wt.eu, keescook@chromium.org, ltp@lists.linux.it, Linus Torvalds <torvalds@linux-foundation.org>, Cristopher Lameter <cl@linux.com>


Hi,

[sorry for the even later reply]

I don't have a strong preference either way (between fs creds or real 
creds), having the same behavior as proc_mem_open sounds like a sensible 
option too. Whether moving pages between NUMA nodes is a read-only 
(PTRACE_MODE_READ) activity is debatable, but I'm no NUMA expert.

My concern here was mainly about a) preventing layout discovery and b) 
consistency between move_pages and migrate_pages.

Otto



On Mon, 29 Jan 2018, Michal Hocko wrote:

> [Fixup Christoph email - the thread starts here
> http://lkml.kernel.org/r/1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com]
>
> On Mon 29-01-18 14:31:51, Michal Hocko wrote:
>> [Sorry for a very late reply]
>>
>> On Wed 10-01-18 10:21:31, Eric W. Biederman wrote:
>> [...]
>>> All of that said.  I am wondering if we should have used
>>> PTRACE_MODE_READ_FSCREDS on these permission checks.
>>
>> If this is really about preventing the layout discovery then we should
>> be in sync with proc_mem_open and that uses PTRACE_MODE_FSCREDS|PTRACE_MODE_READ
>> Should we do the same thing here?
>> --
>> Michal Hocko
>> SUSE Labs
>
> -- 
> Michal Hocko
> SUSE Labs
>
