Message-Id: <20080221212854.408662000@menage.corp.google.com>
Date: Thu, 21 Feb 2008 13:28:54 -0800
From: menage@google.com
Subject: [PATCH 0/2] cgroup map files: Add a key/value map file type to cgroups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com, yamamoto@valinux.co.jp, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

[ Updated from the previous version to remove the colon from the map output ]

These patches add a new cgroup control file output type - a map from
strings to u64 values - and make use of it for the memory controller
"stat" file.

It is intended for use when the subsystem wants to return a collection
of values that are related in some way, for which a separate control
file for each value would make the reporting unwieldy.

The advantages of this are:

- more standardized output from control files that report
similarly-structured data that needs to be parsed programmatically

- less boilerplate required in cgroup subsystems

- simplifies transition to a future efficient cgroups binary API

Signed-off-by: Paul Menage <menage@google.com>


--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
