Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id BD8C16B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 16:53:05 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so5061657pbc.3
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 13:53:05 -0800 (PST)
Date: Tue, 5 Mar 2013 13:53:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
In-Reply-To: <513530B1.8050106@gmail.com>
Message-ID: <alpine.DEB.2.02.1303051352280.28165@chino.kir.corp.google.com>
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
 <511C61AD.2010702@gmail.com> <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com> <51245D48.4030102@gmail.com> <alpine.DEB.2.02.1302192305560.27407@chino.kir.corp.google.com> <51316242.1010206@gmail.com> <alpine.DEB.2.02.1303040317540.12264@chino.kir.corp.google.com>
 <513530B1.8050106@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, 5 Mar 2013, Simon Jeons wrote:

> Then why both need /proc/meminfo and /proc/vmstat?
> 

Because we do not break userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
