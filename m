Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3D1B16B00AE
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:28:09 -0500 (EST)
Received: by mail-bw0-f215.google.com with SMTP id 7so722013bwz.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 08:28:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v0 2/3] res_counter: implement thresholds
Date: Thu, 26 Nov 2009 18:27:37 +0200
Message-Id: <8524ba285f6dd59cda939c28da523f344cdab3da.1259248846.git.kirill@shutemov.name>
In-Reply-To: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
References: <cover.1259248846.git.kirill@shutemov.name>
 <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
In-Reply-To: <cover.1259248846.git.kirill@shutemov.name>
References: <cover.1259248846.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

It allows to setup two thresholds: one above current usage and one
below. Callback threshold_notifier() will be called if a threshold is
crossed.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
