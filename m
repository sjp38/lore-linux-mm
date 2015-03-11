Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id F22A7900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 14:44:53 -0400 (EDT)
Received: by pdjp10 with SMTP id p10so13245559pdj.10
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:44:53 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id em4si758255pac.131.2015.03.11.11.44.51
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 11:44:51 -0700 (PDT)
Date: Wed, 11 Mar 2015 14:44:43 -0400 (EDT)
Message-Id: <20150311.144443.1290707334236248572.davem@davemloft.net>
Subject: Re: [PATCH] mm: kill kmemcheck
From: David Miller <davem@davemloft.net>
In-Reply-To: <55007A9B.4010608@oracle.com>
References: <55004595.7020304@oracle.com>
	<20150311.132052.205877953171712952.davem@davemloft.net>
	<55007A9B.4010608@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 11 Mar 2015 13:25:47 -0400

> You're probably wondering why there are changes to SPARC in that patchset? :)

Libsanitizer doesn't even build have the time on sparc, the release
manager has to hand patch it into building again every major release
because of the way ASAN development is done out of tree and local
commits to the gcc tree are basically written over during the
next merge.

So I'm a little bit bitter about this, as you can see. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
