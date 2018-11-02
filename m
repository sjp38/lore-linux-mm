Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBFB86B000E
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:44:14 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n68so3620807qkn.8
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:44:14 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40133.outbound.protection.outlook.com. [40.107.4.133])
        by mx.google.com with ESMTPS id m4-v6si2376761qtp.48.2018.11.02.05.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Nov 2018 05:44:14 -0700 (PDT)
Received: from eskara-dhcp047134.emea.nsn-net.net (fihel1d-proxy.emea.nsn-net.net [10.158.100.1])
	by fihe3nok0734.emea.nsn-net.net (GMO) with ESMTP id wA2CiBnZ025283
	for <linux-mm@kvack.org>; Fri, 2 Nov 2018 12:44:11 GMT
Message-ID: <1541162651.27706.93.camel@nokia.com>
Subject: NUMA memchr_inv() in mm/vmstat.c:need_update()?
From: Janne Huttunen <janne.huttunen@nokia.com>
Date: Fri, 2 Nov 2018 14:44:11 +0200
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

The commit 1d90ca897A changed the type of the vm_numa_stat_diff
from s8 into u16. It also changed the associated BUILD_BUG_ON()
in need_update(), but didn't touch the memchr_inv() call after
it. Is the memchr_inv() call still supposed to cover the whole
array or am I just misreading the code?
