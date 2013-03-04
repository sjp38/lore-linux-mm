Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 773DC6B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 18:39:37 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id rr4so3575021pbb.13
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 15:39:36 -0800 (PST)
Message-ID: <513530B1.8050106@gmail.com>
Date: Tue, 05 Mar 2013 07:39:29 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com> <511C61AD.2010702@gmail.com> <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com> <51245D48.4030102@gmail.com> <alpine.DEB.2.02.1302192305560.27407@chino.kir.corp.google.com> <51316242.1010206@gmail.com> <alpine.DEB.2.02.1303040317540.12264@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1303040317540.12264@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 03/04/2013 07:18 PM, David Rientjes wrote:
> On Sat, 2 Mar 2013, Simon Jeons wrote:
>
>>> This has nothing to do with this thread, but /proc/vmstat actually does
>>> not include the MemTotal value being discussed in this thread that
>>> /proc/meminfo does.  /proc/meminfo is typically the interface used by
>>> applications, probably mostly for historical purposes since both are
>> Do you mean /proc/vmstat is not used by  applications.
>> sar -B 1
>> pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s pgscand/s pgsteal/s
>> %vmeff
>> I think they are read from /proc/vmstat
>>
> Yes, there is userspace code that parses /proc/vmstat.

Then why both need /proc/meminfo and /proc/vmstat?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
