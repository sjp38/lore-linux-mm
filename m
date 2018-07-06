Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB296B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 17:50:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g7-v6so13859880qtp.19
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 14:50:47 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q20-v6si7138723qtc.328.2018.07.06.14.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 14:50:46 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w66LnE3B138086
	for <linux-mm@kvack.org>; Fri, 6 Jul 2018 21:50:45 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2k0dnju392-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 06 Jul 2018 21:50:45 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w66Loi32001777
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 6 Jul 2018 21:50:45 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w66Loi6k011861
	for <linux-mm@kvack.org>; Fri, 6 Jul 2018 21:50:44 GMT
From: Upendra Gandhi <upendra.gandhi@oracle.com>
Subject: sssd_be
Message-ID: <aa22dc14-68d1-e64d-6c2c-6688ab1ab4ca@oracle.com>
Date: Fri, 6 Jul 2018 14:50:43 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi:

How do we fix the sssd_be issue where is kills the sssd daemon

[302073.601616] sssd_be[643]: segfault at a4 ip 00007f1ade63a5d1 sp 
00007ffe7200ec20 error 4 in libdbus-1.so.3.7.4[7f1ade614000+46000]
[302438.725499] nr_pdflush_threads exported in /proc is scheduled for 
removal
[302438.725575] sysctl: The scan_unevictable_pages sysctl/node-interface 
has been disabled for lack of a legitimate use case.A  If you have one, 
please send an email to linux-mm@kvack.org

thanks
