Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AA0A46B0005
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:09:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bg4so3846121pad.26
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 23:09:48 -0800 (PST)
Date: Tue, 19 Feb 2013 23:09:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
In-Reply-To: <51245D48.4030102@gmail.com>
Message-ID: <alpine.DEB.2.02.1302192305560.27407@chino.kir.corp.google.com>
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
 <511C61AD.2010702@gmail.com> <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com> <51245D48.4030102@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Wed, 20 Feb 2013, Simon Jeons wrote:

> What I confuse is why have /proc/meminfo and /proc/vmstat at the same time,
> they both use to monitor memory subsystem states. What's the root reason?
> 

This has nothing to do with this thread, but /proc/vmstat actually does 
not include the MemTotal value being discussed in this thread that 
/proc/meminfo does.  /proc/meminfo is typically the interface used by 
applications, probably mostly for historical purposes since both are 
present when procfs is configured and mounted, but also to avoid 
determining the native page size.  There's no implicit userspace API 
exported by /proc/vmstat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
