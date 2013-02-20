Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 738F66B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:05:32 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so3330234dak.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 23:05:31 -0800 (PST)
Date: Tue, 19 Feb 2013 23:05:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM triggered with plenty of memory free
In-Reply-To: <5124641C.5020209@gmail.com>
Message-ID: <alpine.DEB.2.02.1302192302270.27407@chino.kir.corp.google.com>
References: <20130213031056.GA32135@marvin.atrad.com.au> <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com> <5124641C.5020209@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jonathan Woithe <jwoithe@atrad.com.au>, linux-mm@kvack.org

On Wed, 20 Feb 2013, Simon Jeons wrote:

> I read drivers/staging/android/lowmemorykiller.c, it seems that android's oom
> just care about oom_score/oom_score_adj exported in /proc which will lead to
> good user experience, but who will set these values if users playing android
> mobiles? Is there userspace monitor process will do it? If the answer is yes,
> then how it determines one process is important or not?
> 

It's up to userspace to determine how to adjust oom priorities for 
processes, whether you're using the Android low memory killer or the 
kernel oom killer.  Many open source packages modify these values for 
themselves directly, but any process can elevate the oom_score_adj value 
for any other process making it more preferable for oom kill; processes 
cannot lower oom_score_adj, itself included, unless it has the 
SYS_RESOURCE capability.  Everything else is left to userspace since the 
kernel has no knowledge of what is important and what is not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
