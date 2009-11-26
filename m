Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D87646B00AE
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:28:06 -0500 (EST)
Received: by mail-bw0-f215.google.com with SMTP id 7so722013bwz.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 08:28:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v0 1/3] cgroup: implement eventfd-based generic API for notifications
Date: Thu, 26 Nov 2009 18:27:36 +0200
Message-Id: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
In-Reply-To: <cover.1259248846.git.kirill@shutemov.name>
References: <cover.1259248846.git.kirill@shutemov.name>
In-Reply-To: <cover.1259248846.git.kirill@shutemov.name>
References: <cover.1259248846.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

This patch introduces write-only file "cgroup.event_control" in every
cgroup.

To register new notification handler you need:
- create an eventfd;
- open a control file to be monitored. Callbacks register_event() and
  unregister_event() must be defined for the control file;
- write "<event_fd> <control_fd> <args>" to cgroup.event_control.
  Interpretation of args is defined by control file implementation;

eventfd will be woken up by control file implementation or when the
cgroup is removed.

To unregister notification handler just close eventfd.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
