Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 689F36B024B
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:09:03 -0400 (EDT)
Date: Fri, 7 May 2010 17:07:59 +0300
From: Ozgur Yuksel <ozgur.yuksel@oracle.com>
Subject: Re: [Bugme-new] [Bug 15610] New: fsck leads to swapper - BUG:
 unable to handle kernel NULL pointer dereference & panic
Message-ID: <20100507140759.GA22664@oracle.com>
References: <bug-15610-10286@https.bugzilla.kernel.org/>
 <20100322100954.5ecaec4b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322100954.5ecaec4b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

During bisecting, I needed to switch to another environment (Xen HVM - Fedora 
12) where I could never reproduce the problem there. I cannot proceed on
analysis on the original environment as it is my main workstation. 

FWIW I can confirm the problem did not reproduce on 2.6.34-rc3 on the original
environment too. 

Ozgur Yuksel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
