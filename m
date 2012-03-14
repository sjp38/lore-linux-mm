Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4241E6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 13:14:36 -0400 (EDT)
From: Andor Daam <andor.daam@googlemail.com>
Subject: frontswap/cleancache: allow backends to register after init
Date: Wed, 14 Mar 2012 18:13:26 +0100
Message-Id: <1331745208-1010-1-git-send-email-andor.daam@googlemail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, ilendir@googlemail.com, konrad.wilk@oracle.com, fschmaus@gmail.com, i4passt@lists.informatik.uni-erlangen.de, ngupta@vflare.org

These two patches allow backends to register to frontswap and cleancache
after initialization and after swapon was run respectively filesystems
were mounted. This should be a first step to allow insmodding of backends
like zcache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
