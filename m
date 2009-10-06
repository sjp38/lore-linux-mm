Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B06CD6B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 14:13:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E25C382C3A5
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 14:17:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QsZg29lq6Pvr for <linux-mm@kvack.org>;
	Tue,  6 Oct 2009 14:16:54 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4C2E282C3CF
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 14:16:14 -0400 (EDT)
Date: Tue, 6 Oct 2009 14:06:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2][RFC] add MAP_UNLOCKED mmap flag
In-Reply-To: <20091006170218.GM9832@redhat.com>
Message-ID: <alpine.DEB.1.10.0910061406060.18309@gentwo.org>
References: <20091006170218.GM9832@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Looks good.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
