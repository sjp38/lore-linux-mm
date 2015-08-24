Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id A22A96B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 19:20:19 -0400 (EDT)
Received: by ykbi184 with SMTP id i184so138585164ykb.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:20:19 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id u184si11369504yku.138.2015.08.24.16.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 16:20:18 -0700 (PDT)
Date: Mon, 24 Aug 2015 19:20:15 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
Message-ID: <20150824232015.GA11651@thunk.org>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150824201952.5931089.66204.70511@amd.com>
 <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartshorn <jhartshorn@connexity.com>
Cc: "Bridgman, John" <John.Bridgman@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Part of the problem with asking "Does anyone use THP" is that a lot of
people may be using THP without realizing it.  That is, after all, the
whole point.

Some selected bits from running the command:

sudo grep -e AnonHugePages  /proc/*/smaps | awk  '{ if($2>4) print $0} ' |  awk -F "/"  '{print $0; system("ps -fp " $3)} '

/proc/17297/smaps:AnonHugePages:    290816 kB
UID        PID  PPID  C STIME TTY          TIME CMD
tytso    17297 17290  4 19:10 pts/6    00:00:05 qemu-system-x86_64 -enable-kvm -boo

/proc/2467/smaps:AnonHugePages:     92160 kB
UID        PID  PPID  C STIME TTY          TIME CMD
tytso     2467  2347  0 09:49 ?        00:00:10 xfdesktop --display :0.0 --sm-clien

/proc/13446/smaps:AnonHugePages:     81920 kB
UID        PID  PPID  C STIME TTY          TIME CMD
tytso    13446  2591  0 12:25 pts/0    00:00:11 mutt -f /home/tytso/imap/shared.mit

/proc/2603/smaps:AnonHugePages:     43008 kB
UID        PID  PPID  C STIME TTY          TIME CMD
tytso     2603  2347  0 09:49 ?        00:00:01 /usr/bin/perl /usr/bin/parcimonie

/proc/9853/smaps:AnonHugePages:     20480 kB
UID        PID  PPID  C STIME TTY          TIME CMD
tytso     9853  2461  1 09:56 ?        00:07:01 /opt/google/chrome-beta/chrome --us

/proc/1622/smaps:AnonHugePages:     14336 kB
UID        PID  PPID  C STIME TTY          TIME CMD
root      1622  1567  0 09:49 tty7     00:03:09 /usr/bin/X :0 -seat seat0 -auth /va

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
