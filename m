Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6E6426B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 21:55:34 -0400 (EDT)
Message-ID: <51C8F861.9010101@asianux.com>
Date: Tue, 25 Jun 2013 09:54:41 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [Suggestion] arch: s390: mm: the warnings with allmodconfig and "EXTRA_CFLAGS=-W"
References: <51C8F685.6000209@asianux.com>
In-Reply-To: <51C8F685.6000209@asianux.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com, cornelia.huck@de.ibm.com, mtosatti@redhat.com, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org

Hello Maintainers:

When allmodconfig for " IBM zSeries model z800 and z900"

It will report the related warnings ("EXTRA_CFLAGS=-W"):
  mm/slub.c:1875:1: warning: ?deactivate_slab? uses dynamic stack allocation [enabled by default]
  mm/slub.c:1941:1: warning: ?unfreeze_partials.isra.32? uses dynamic stack allocation [enabled by default]
  mm/slub.c:2575:1: warning: ?__slab_free? uses dynamic stack allocation [enabled by default]
  mm/slub.c:1582:1: warning: ?get_partial_node.isra.34? uses dynamic stack allocation [enabled by default]
  mm/slub.c:2311:1: warning: ?__slab_alloc.constprop.42? uses dynamic stack allocation [enabled by default]

Is it OK ?


Thanks.
--
Chen Gang

Asianux Corporation 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
