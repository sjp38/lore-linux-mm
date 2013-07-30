Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 236056B0032
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 16:46:58 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fq13so4473619lab.25
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 13:46:56 -0700 (PDT)
Message-Id: <20130730204154.407090410@gmail.com>
Date: Wed, 31 Jul 2013 00:41:54 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [patch 0/2] Soft-dirty page tracker improvemens
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

Hi, as being reported by Andy, there are a couple of situations
when soft-dirty bit will be lost, in paricular when page we're
tracking is going to swap and when file page get reclaimed. In
this series both problems are aimed.

One more hardness which remains is the scenario when vma area
(which has soft-dirty bit set in appropriate pte entries) get
unmapped then new one mapped in-place. I'm working on it now
hope to provide a patch soon.

Thanks,
	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
