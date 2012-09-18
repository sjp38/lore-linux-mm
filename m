Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 620ED6B0089
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:13:53 -0400 (EDT)
Received: by qafk30 with SMTP id k30so2937843qaf.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 06:13:52 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 18 Sep 2012 16:13:52 +0300
Message-ID: <CAFS8ZhKcnfayLQLzUPyD5qEtAEbPEf0Ab=BYdXBZ3gR32NantQ@mail.gmail.com>
Subject: bugreport
From: Dmitriy Bukach <bukach@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi


[71287.717849] process `sysctl' is using deprecated sysctl (syscall)
net.ipv6.neigh.bond0.base_reachable_time; Use
net.ipv6.neigh.bond0.base_reachable_time_ms instead.
[71287.720563] sysctl: The scan_unevictable_pages
sysctl/node-interface has been disabled for lack of a legitimate use
case.  If you have one, please send an email to linux-mm@kvack.org.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
