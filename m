Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D3376B0089
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:14:52 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5E8E482C38F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:27:51 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id N8TJHQntZehH for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:27:46 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DC3D382C39C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:27:32 -0400 (EDT)
Date: Thu, 14 May 2009 16:11:52 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] migration: only migrate_prep() once per move_pages()
In-Reply-To: <4A0A600F.9010801@inria.fr>
Message-ID: <alpine.DEB.1.10.0905141611410.15881@qirst.com>
References: <49E58D7A.4010708@ens-lyon.org> <20090415164955.41746866.kamezawa.hiroyu@jp.fujitsu.com> <4A0A600F.9010801@inria.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


I acked it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
